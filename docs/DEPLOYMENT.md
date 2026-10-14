# FieldNote production deployment

This is the checklist for a production (or staging) release of FieldNote.
See [`PRODUCTION_GAPS.md`](PRODUCTION_GAPS.md) for release limitations.
Nothing in this repository holds a real production value. Every host, ID, key
and password is supplied at build or deploy time.

Placeholders used below:

| Placeholder     | Meaning                                                                                                                                                                           |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<api-host>`  | Public host of the Serverpod API server (port 8080 behind TLS)                                                                                                                    |
| `<web-host>`  | Public host of the Serverpod web server (port 8082 behind TLS); serves the Flutter web app,`/c/<slug>` share pages, `/legal/*`, `/.well-known/*` and `/webhooks/razorpay` |
| `<link-host>` | Host used in shared campaign links`https://<link-host>/c/<slug>`. Normally the same as `<web-host>`                                                                           |
| `<app-id>`    | Android application ID / iOS bundle ID you own (reverse DNS). Must not start with`com.example`                                                                                  |
| `<TEAM_ID>`   | Apple Developer team ID                                                                                                                                                           |

---

## 1. Server image and secrets

Build from the repository root (the build context is the root, so the root
[`.dockerignore`](../.dockerignore) applies):

```sh
docker build -f fieldnotes_server/Dockerfile -t fieldnote-server .
```

`config/passwords.yaml`, `.env*`, keystores, `.dart_tool`, `build`, the
embedded-Postgres `.serverpod/` directory and `fieldnotes_server/test` are
excluded from the context. The Dockerfile also deletes `passwords.yaml` in the
build stage as a second line of defence, so **the image never contains secrets.**

### Password environment-variable convention (Serverpod 4.0.0)

Verified in `serverpod_shared-4.0.0/lib/src/password_manager.dart`:

- Any environment variable named **`SERVERPOD_PASSWORD_<key>`** becomes the
  password `<key>`. The suffix is used **verbatim and case-sensitively**, so it
  must match the passwords.yaml key exactly: `SERVERPOD_PASSWORD_razorpayKeySecret`,
  not `SERVERPOD_PASSWORD_RAZORPAY_KEY_SECRET`.
- Three built-in passwords also have dedicated names:
  `SERVERPOD_DATABASE_PASSWORD` (`database`), `SERVERPOD_REDIS_PASSWORD`
  (`redis`), `SERVERPOD_SERVICE_SECRET` (`serviceSecret`). The generic form
  (`SERVERPOD_PASSWORD_database`) works too, as CI already uses it.
- Precedence: `passwords.yaml` `shared:` < `passwords.yaml` `<runmode>:` <
  environment variables. With no `passwords.yaml` in the image, env vars are
  the only source.

Store these in your platform's secret manager and inject them as env vars.

### Required passwords

Derived from `session.passwords[...]` / `getPassword(...)` in
`fieldnotes_server/lib` and from the Serverpod auth packages that `server.dart`
configures (`JwtConfigFromPasswords`, `EmailIdpConfigFromPasswords`).

| Key (`SERVERPOD_PASSWORD_<key>`) | Required                              | Used by                                                                                                                                                              |
| ---------------------------------- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `database`                       | Yes                                   | PostgreSQL password (or`SERVERPOD_DATABASE_PASSWORD`)                                                                                                              |
| `serviceSecret`                  | Yes                                   | Serverpod service/Insights auth (or`SERVERPOD_SERVICE_SECRET`)                                                                                                     |
| `redis`                          | Yes once Redis is on            | Redis password (or`SERVERPOD_REDIS_PASSWORD`)                                                                                                                      |
| `jwtHmacSha512PrivateKey`        | Yes                                   | JWT access-token signing (`JwtConfigFromPasswords`)                                                                                                                |
| `jwtRefreshTokenHashPepper`      | Yes                                   | JWT refresh-token hashing; at least 10 characters                                                                                                                    |
| `emailSecretHashPepper`          | Yes                                   | Email IdP password/code hashing (`EmailIdpConfigFromPasswords`)                                                                                                    |
| `smtpUsername`                   | Yes                                   | Sender account for verification/password-reset email (`lib/src/auth/verification_email_sender.dart`) and transactional notifications (`NotificationService`)     |
| `smtpAppPassword`                | Yes                                   | SMTP app password for that account                                                                                                                                   |
| `smtpHost`, `smtpPort`         | Optional                              | Notifications only: any STARTTLS provider instead of Gmail (port defaults to 587). Without SMTP passwords notifications are marked`skipped`, never fail the action |
| `razorpayKeyId`                  | Yes                                   | Razorpay key ID. Live keys start`rzp_live_`. Payout simulation runs only with `rzp_test_` keys; with live keys it answers `payouts_manual` (section 7)         |
| `razorpayKeySecret`              | Yes                                   | Razorpay order creation and checkout-signature verification                                                                                                          |
| `razorpayWebhookSecret`          | Yes                                   | Verifies`X-Razorpay-Signature` on the web-server route `/webhooks/razorpay`                                                                               |
| `geminiApiKey`                   | One of Gemini/Groq is required | Campaign drafting, evidence summaries, dictation transcription                                                                                                       |
| `groqApiKey`                     | See above                             | Fallback/alternative AI provider                                                                                                                                     |
| `aiPrimaryProvider`              | Optional                              | `gemini` or `groq`; chooses which provider is tried first                                                                                                        |
| `geminiModel`                    | Optional                              | Overrides the default Gemini model (`GeminiAiService.defaultModel`). The non-secret env var `FIELDNOTE_GEMINI_MODEL` works too; the password wins                |
| `geminiTranscriptionModel`       | Optional                              | Overrides the Gemini speech model                                                                                                                                    |
| `googleMapsApiKey`               | Optional                              | Server-side Places, Geocoding and Routes (never load-bearing)                                                                                                        |

Rotate every value that was ever used in development. Do not reuse the dev or
CI database/Redis passwords committed in `docker-compose.yaml` and
`.github/workflows/tests.yml`; they are local/test-only.

### Non-secret server configuration (domain is env-configurable)

`config/production.yaml` and `config/staging.yaml` contain **no real hosts**:
every host is `localhost` with a `# REQUIRED: SERVERPOD_…` comment, so a
forgotten override fails safe instead of pointing at someone else's domain.
Serverpod merges these env vars over the YAML (`serverpod_shared`
`_buildConfigMap`, verified against 4.0.0):

| Env var                                                                             | Required      | Value                                                                                                                                                                                                                         |
| ----------------------------------------------------------------------------------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `SERVERPOD_API_SERVER_PUBLIC_HOST`                                                | Yes           | `<api-host>`                                                                                                                                                                                                                |
| `SERVERPOD_WEB_SERVER_PUBLIC_HOST`                                                | Yes           | `<web-host>`. Also used to build legal URLs and server-generated share links                                                                                                                                                |
| `SERVERPOD_INSIGHTS_SERVER_PUBLIC_HOST`                                           | Optional      | Insights host (keep it private if possible)                                                                                                                                                                                   |
| `SERVERPOD_DATABASE_HOST`, `_PORT`, `_NAME`, `_USER`, `_REQUIRE_SSL`      | Host required | Managed Postgres (YAML defaults: port 5432, name`fieldnote`, user `postgres`, SSL on)                                                                                                                                     |
| `SERVERPOD_REDIS_HOST`, `_PORT`, `_USER`, `_REQUIRE_SSL`, `_ENABLED`      | Host required | Redis is**enabled** in both files; see section 5                                                                                                                                                                  |
| `SERVERPOD_ALLOWED_ORIGINS`                                                       | Yes           | `https://<web-host>` (comma-separated). The YAML placeholder `https://localhost` rejects real browsers' WebSockets until this is set. Native apps send no `Origin` and are unaffected                                   |
| `SERVERPOD_AUTH_COOKIE_DOMAIN`, `_SECURE`, `_SAME_SITE`, `_NAME`, `_PATH` | Optional      | `authCookie` is configured (`sameSite: lax`, `secure: true`). The web app keeps bearer tokens until it sets `client.cookieAuth = true`. Serverpod refuses to boot if `authCookie` is set without `allowedOrigins` |
| `SERVERPOD_WEB_SERVER_STATIC_CACHE_CONTROL`                                       | Optional      | Static files under`/web/` default to `public, immutable, max-age=1 year`                                                                                                                                                  |

FieldNote's own non-secret settings (read by `lib/src/fieldnotes/services/fieldnote_config.dart`):

| Env var                                        | Required                   | Value                                                                                                                                            |
| ---------------------------------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `FIELDNOTE_ANDROID_PACKAGE`                  | For App Links / share page | Android application ID (`<app-id>`). Used in the share page's `intent://` link and `assetlinks.json`; the page omits the intent when unset |
| `FIELDNOTE_ANDROID_SHA256_CERT_FINGERPRINTS` | For App Links              | Comma-separated`AA:BB:…` SHA-256 fingerprints (Play app-signing key, optionally upload key)                                                   |
| `FIELDNOTE_IOS_APP_ID`                       | For Universal Links        | `<TEAM_ID>.<app-id>`                                                                                                                           |
| `FIELDNOTE_PLAY_STORE_URL`                   | Optional                   | Store link on the share page; defaults to`https://play.google.com/store/apps/details?id=<FIELDNOTE_ANDROID_PACKAGE>`                           |
| `FIELDNOTE_APP_STORE_URL`                    | Optional                   | App Store link on the share page                                                                                                                 |
| `FIELDNOTE_LINK_BASE_URL`                    | Optional                   | `https://<link-host>` when share/legal links must not use the web server's public host                                                         |
| `FIELDNOTE_GEMINI_MODEL`                     | Optional                   | Gemini model when the`geminiModel` password is unset                                                                                           |

`config/development.yaml` uses `localhost` for every host. To test on a phone
or through a tunnel, set `SERVERPOD_API_SERVER_PUBLIC_HOST` (and `_PORT`,
`_SCHEME`) in the shell instead of editing the file.

The container already sets `runmode=production`; pass `--mode=staging` via
`runmode=staging` for staging.

---

## 2. App identity and signing

The application/bundle ID is a **required build setting with no real default**.
Debug and profile builds use the obvious placeholders `com.example.fieldnotes_flutter`
(Android) and `com.example.fieldnotesFlutter` (iOS). Release builds **fail** if
the ID is missing or still starts with `com.example`.

### Android

1. Create an upload keystore (keep it out of the repo; `*.jks`/`*.keystore` are git-ignored):
   ```sh
   keytool -genkey -v -keystore ~/fieldnote-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. `cp fieldnotes_flutter/android/key.properties.example fieldnotes_flutter/android/key.properties`
   and fill in `fieldnote.applicationId`, `fieldnote.linkHost`, `storeFile`
   (relative to `android/` or absolute), `storePassword`, `keyAlias`, `keyPassword`.
3. Alternatives for CI: Gradle properties (`-Pfieldnote.applicationId=…`, or
   `~/.gradle/gradle.properties`), or env vars `FIELDNOTE_APPLICATION_ID`,
   `FIELDNOTE_LINK_HOST`, `FIELDNOTE_KEYSTORE_PATH`, `FIELDNOTE_KEYSTORE_PASSWORD`,
   `FIELDNOTE_KEY_ALIAS`, `FIELDNOTE_KEY_PASSWORD`.
4. The `:app:validateFieldnoteRelease` task runs before `preReleaseBuild` and
   throws a `GradleException` listing every missing value. Release builds never
   fall back to the debug key.
5. Enrol in Play App Signing. Put the **app signing key** SHA-256 (Play Console >
   App integrity), and the upload key SHA-256 if you side-load upload-signed
   builds, in `assetlinks.json` (section 3).

The Kotlin `namespace` stays `com.example.fieldnotes_flutter`. It is the R/
BuildConfig package, is never visible to users and is independent of the
application ID. Renaming it means moving `MainActivity.kt` too; that is optional.

Cleartext HTTP is enabled only in `src/debug` and `src/profile`
manifests for local servers. Release builds are HTTPS-only.

### iOS

1. `cp fieldnotes_flutter/ios/Flutter/AppIdentity.local.xcconfig.example fieldnotes_flutter/ios/Flutter/AppIdentity.local.xcconfig`
   (git-ignored), then uncomment and set `FIELDNOTE_BUNDLE_ID`,
   `FIELDNOTE_LINK_HOST` and optionally `DEVELOPMENT_TEAM`.
2. `ios/Flutter/AppIdentity.xcconfig` (committed, placeholders only) is included
   from `Debug.xcconfig` and `Release.xcconfig`, and it `#include?`s the local file.
   The Runner target sets `PRODUCT_BUNDLE_IDENTIFIER = $(FIELDNOTE_BUNDLE_ID)`
   and `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`.
3. The **Validate FieldNote App Identity** build phase fails `Release` builds when
   the bundle ID is empty or `com.example.*`, or the link host is empty or `localhost`.
4. In the Apple Developer portal, enable **Associated Domains** for the App ID.
   Automatic signing does this when the team is set.
5. `RunnerTests` keeps a `com.example…RunnerTests` ID; it is never shipped.

### Flutter build defines

```sh
flutter build appbundle --release \
  --dart-define=SERVER_URL=https://<api-host>/ \
  --dart-define=CAMPAIGN_SHARE_BASE_URL=https://<link-host>
flutter build ipa --release \
  --dart-define=SERVER_URL=https://<api-host>/ \
  --dart-define=CAMPAIGN_SHARE_BASE_URL=https://<link-host>
```

`CAMPAIGN_SHARE_BASE_URL` makes shared links `https://<link-host>/c/<id>`;
without it the app shares `fieldnote://campaign/<id>`.

---

## 3. Deep links: App Links and Universal Links

- **Android:** `AndroidManifest.xml` has an `android:autoVerify="true"` filter
  for `https://${fieldnoteLinkHost}/c/…`. The manifest placeholder comes from
  `fieldnote.linkHost` (`localhost` in debug/profile). The `fieldnote://campaign`
  scheme is kept.
- **iOS:** `Runner.entitlements` declares
  `com.apple.developer.associated-domains = applinks:$(FIELDNOTE_LINK_HOST)`.
- `campaignIdFromDeepLink` in the app already accepts `https://<any-host>/c/<id>`.

`<link-host>` must serve these two files over HTTPS at exactly these paths,
with `Content-Type: application/json`, status 200 and **no redirects**. The
web server now generates both (`lib/src/web/routes/well_known_routes.dart`,
one-hour cache) from `FIELDNOTE_ANDROID_PACKAGE` +
`FIELDNOTE_ANDROID_SHA256_CERT_FINGERPRINTS` and `FIELDNOTE_IOS_APP_ID`. Each
answers **404 until its variables are set**. Malformed values are ignored (a
fingerprint must be 32 colon-separated hex pairs; the iOS ID must be
`TEAMID.bundle`). The generated documents match the templates below.

### `https://<link-host>/.well-known/assetlinks.json`

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "<app-id>",
      "sha256_cert_fingerprints": [
        "<PLAY_APP_SIGNING_KEY_SHA256 e.g. 14:6D:E9:...>",
        "<UPLOAD_KEY_SHA256 (optional)>"
      ]
    }
  }
]
```

Check it with
`https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://<link-host>&relation=delegate_permission/common.handle_all_urls`
and on a device with `adb shell pm get-app-links <app-id>`.

### `https://<link-host>/.well-known/apple-app-site-association`

No file extension.

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["<TEAM_ID>.<app-id>"],
        "components": [
          { "/": "/c/*", "comment": "Shared FieldNote campaign links" }
        ]
      }
    ]
  }
}
```

Apple fetches this through its CDN when the app is installed, so changes can
take up to about a day to apply. Check it with
`https://app-site-association.cdn-apple.com/a/v1/<link-host>`.

### Share links

- Every campaign has an unguessable `shareSlug` (22 base62 characters; rows
  created before it existed were backfilled by migration
  `20261001143105843-compliance-notifications`). `getCampaignShareLink`
  returns `https://<web-host>/c/<slug>` and the app resolves it with
  `getSharedCampaignBySlug`.
- `/c/<slug>` and the legacy `/c/<id>` render **only open campaigns** (active,
  not cancelled/expired, not started). Drafts, cancelled, expired, started and
  completed campaigns return 404.
- The Android `intent://` uses `FIELDNOTE_ANDROID_PACKAGE`; the page links to
  the store URLs above. The locally built APK (`/download/fieldnote.apk` and
  its button) exists **only in the `development` run mode**.
- The app's deep-link parser still only accepts numeric ids; the UI pass must
  accept `/c/<slug>` too (call `getSharedCampaignBySlug`).

---

## 4. Legal documents

Drafts live in `fieldnotes_server/web/static/legal/`. **Both need legal review**
(see the HTML comment at the top of each), with every `[PLACEHOLDER]` replaced.

| Document         | URL                                  | Version constant                                            |
| ---------------- | ------------------------------------ | ----------------------------------------------------------- |
| Privacy Policy   | `https://<web-host>/legal/privacy` | `FieldnoteEndpoint.privacyPolicyVersion` (`2026-09-22`) |
| Terms of Service | `https://<web-host>/legal/terms`   | `FieldnoteEndpoint.termsVersion` (`2026-09-22`)         |

`/legal/privacy` and `/legal/terms` serve the same files with
`Cache-Control: public, max-age=300`, so updates reach clients within five
minutes. (`/web/legal/*.html` still works but is cached for a year; do not link
it.) The unauthenticated `legal.getLegalPolicies()` RPC returns both versions,
both URLs (built from the web server's public host) and the required consent
switches, so signup and onboarding never hardcode them. Bump the HTML
version and the endpoint constants together, then link both URLs from signup,
onboarding, the consent gate, the Trust area and both store listings.

Consent: `acceptLegalConsent` stores the switches the user actually set
and rejects the call unless all three are true; when the client passes
`acceptedPrivacyPolicyVersion` / `acceptedTermsVersion` a stale version is
rejected with `consent_version_mismatch`. `withdrawConsent` turns all three
off, which makes every role-gated RPC answer `consent_required`. Every accept
and withdraw is appended to `fieldnote_legal_consent_history`
(`listMyConsentHistory`).

---

## 5. Redis

Redis is **enabled** in `production.yaml` and `staging.yaml` (TLS on, port
6379) so `session.messages`, live campaign streams and auth revocation reach
every instance. Set `SERVERPOD_REDIS_HOST` and `SERVERPOD_REDIS_PASSWORD`
(plus `_PORT`/`_USER`/`_REQUIRE_SSL` if they differ). A single-instance
deployment without Redis must set `SERVERPOD_REDIS_ENABLED=false` explicitly.

Rate limits do **not** need Redis: `RateLimiter` keeps fixed-window
counters in `fieldnote_rate_limit_bucket` with one atomic upsert per call, so
they hold across instances. Limits (per user, per window) are constants in
`services/rate_limiter.dart`: campaign drafting 20/h, dictation 30/h,
evidence analysis 20/h, Maps (Places/geocode/routes/reach) 600/h, matching
240/h, order creation 20/h, share links and invites 60/h, deletion requests
5/day, data export 10/day. Over the limit the RPC throws `FieldnoteException`
code `rate_limited` with `retryAfterSeconds`.

## 6. Email (SMTP)

Signup verification and password-reset codes are emailed by
`lib/src/auth/verification_email_sender.dart` using `smtpUsername` and
`smtpAppPassword`. The sender includes the code in the email body; its failure
log records the delivery error and recipient, without explicitly logging the code.

Transactional email notifications go through an outbox. The private inbox and
Android push are configured separately; see [`NOTIFICATIONS.md`](NOTIFICATIONS.md).

- Business actions insert rows into `fieldnote_notification_outbox`; one row
  per `(recipient, dedupeKey)`, so retries never send twice. Events:
  campaign cancelled / expired ("do not travel"), postponed, revised and
  confirmed (to volunteers holding a place), invitation received, payment
  verified and refund processed (to the sponsor), evidence approved / rejected
  (to the volunteer), account deletion completed.
- The `fieldnote-outbox` future call (every minute, registered in
  `server.dart`) delivers rows with plain-text and HTML bodies, retrying
  failures with backoff up to 5 attempts. Addresses are looked up from the
  Serverpod auth email account at send time and never stored, except the
  deletion notice (captured before the login is deleted, cleared once sent).
- Without SMTP passwords rows are marked `skipped` (`smtp_not_configured`) and
  the business action is unaffected. Users opt out with
  `setEmailNotifications(false)` (`FieldnoteUserProfile.emailNotifications`);
  the deletion notice is always sent.

Use a dedicated sending account or a transactional provider (`smtpHost`), and
set up SPF, DKIM and DMARC for the sending domain.

## 7. Payments: Razorpay live mode

1. Complete Razorpay KYC and activate live mode.
2. Set `razorpayKeyId` (`rzp_live_…`) and `razorpayKeySecret` from the live dashboard.
3. Add a webhook in the Razorpay dashboard (Settings > Webhooks):
   - URL: `https://<web-host>/webhooks/razorpay` (Serverpod web-server route)
   - Secret: a new random value, stored as **`razorpayWebhookSecret`**
   - Events: at least `payment.captured`, `payment.failed`, `order.paid`,
     `refund.processed`, `refund.failed`
4. Web retry, webhook reconciliation and expiry refunds are implemented. `TestRefund` rows are real Razorpay refunds in
   live mode (the class name is historical). `TestPayout` rows are a
   Test Mode simulation only.
5. In the web build, `index.html` loads `https://checkout.razorpay.com/v1/checkout.js`.
   Allow it in any Content-Security-Policy.

### Money storage

All money is stored as integer paise in `*Paise` columns: `Campaign.fundingGoalPaise`,
`sponsoredAmountPaise` (net of refunds) and `refundedAmountPaise`; `Sponsorship.amountPaise`;
`TestRefund.amountPaise`; and `TestPayout.amountPaise`. These columns are the source of truth.
For clients older than this release, the server keeps writing the old rupee `double` fields as
`paise / 100`. Migration `20261002062415263-money-paise-idempotency` backfills the paise
columns. It also takes refunds that were processed before this release off their campaign's
funded amount.

### Payouts: manual settlement in live mode

**Who is paid.** Sponsors pay into a campaign through Razorpay Checkout.
Once a campaign is `completed`, its verified, non-refunded sponsorships are
due to the **campaign creator**: the sponsor who organised the campaign
(`Campaign.createdBy`, `TestPayout.creatorAuthUserId`). That creator runs the
volunteer event.

**Test Mode.** `simulateCampaignTestPayout` writes `TestPayout` ledger rows only with `rzp_test_` keys. It never transfers money. The existing simulation remains available on the creator payout screen, and explicitly live payment rows are excluded from it.

**Live requests.** The creator opens **Impact → Payout → Request payout** after campaign completion. `requestManualPayout` requests the entire currently available gross balance and snapshots its source sponsorship IDs. A campaign row lock, unique client request ID and source reservations prevent duplicate withdrawals. `requested`, `processing` and `paid` requests reserve their sources; rejection releases them. Fees consumed by a paid request never become withdrawable again.

Only verified Razorpay sponsorships created with `paymentTestMode = false`, a payment ID and verification timestamp qualify. Any refund row excludes that payment, regardless of refund status. Existing test credits also exclude it. The server requires `rzp_live_` credentials to accept a real request. Old sponsorships have a null mode marker and are deliberately ineligible; do not mass-backfill them using the currently configured key. Reconcile any legacy obligations separately before paying them.

**Operations access.** Configure `FIELDNOTE_PAYOUT_OPERATOR_IDS` with a comma-separated allowlist of trusted Serverpod auth user UUIDs. It is empty by default. Operators keep their Sponsor or Volunteer account role; there is no third product role and users cannot grant themselves this permission. Restart the server after changing this environment variable. Allowlisted accounts see **Profile → Payout operations**. The server independently checks the allowlist on every queue/review/payment RPC.

To find the operator's own UUID, sign into that account, export JSON from the Trust area and read `profile.authUserId`. Configure only trusted account IDs, not display names or email addresses. Keep the rest of that export private.

```sh
# Replace with the trusted operator's real auth UUID. This is not an API secret.
FIELDNOTE_PAYOUT_OPERATOR_IDS='your-operator-auth-uuid'
```

**Manual settlement process:**

1. Open the operations queue. Match the campaign and creator auth UUID to the verified creator and your external payee record. Obtain their contact information from your existing creator onboarding records. Collect and verify bank details outside FieldNote; never put account numbers or KYC documents into the app's reference or note fields.
2. Review the request's source payment IDs in `fieldnote_manual_payout_request.sponsorshipIds` and match those sponsorships to Razorpay captured payments. Confirm their settlement into the business bank account and check for refunds or disputes. The app does not verify bank settlement automatically.
3. Select **Approve for transfer**, enter opaque settlement and payee verification record references, any deductions agreed with the creator, and a creator-visible explanation. INR deductions are stored as exact integer paise. The approved transfer amount is gross minus deductions. Approval changes the request to `processing` and does not initiate a transfer. Source eligibility is rechecked when approving.
4. Recheck provider/bank status before sending money. Transfer exactly the approved net amount through your bank. Keep funds reserved if the outcome is uncertain; do not send another transfer until you have reconciled the first. A `processing` request cannot be rejected to release funds.
5. Once the bank confirms success, select **Record completed transfer** and enter its UTR/reference. The request changes to `paid`; the creator sees the amount and reference in payout history after refresh. References are normalized to uppercase and unique across requests. Retrying the same reference on the same paid request is safe. Recording paid does not itself send money.
6. Reject a `requested` payout with a reason when payee verification or settlement cannot be completed. Reject before transferring any money. The creator can submit a new request when eligible funds remain.

Request, approval/rejection and paid transitions are persisted with an audit event in the same database transaction. This app stores payout history, but it does not execute bank transfers, fetch bank settlements, handle chargebacks automatically or send payout-status emails. Creators can refresh the payout screen to see status changes. Pending creator requests block account deletion; completed financial records are retained with anonymized user IDs, and creator payout history is included in the JSON data export.

**Migration:** `20261004185915672-manual-payouts` adds the payout table and nullable checkout-mode column. Deploy/apply it before serving clients with this feature. Local `serverpod start` applies pending migrations; staging and production should follow the normal backup/deploy process.

## 8. Database and storage backups

- Use managed PostgreSQL with automated daily backups, point-in-time recovery
  (7 days or more) and `requireSsl: true`.
- Evidence photos live in Serverpod private cloud storage. On a self-hosted
  server this falls back to `DatabaseCloudStorage`, so the photos sit in the
  database and its backups. Size and encrypt the backups for that. Prefer an S3/GCS
  bucket in production.
- Rehearse a restore before launch. Deletion requests must also be
  honoured against backups within the stated retention period.
- `serverpod start`/the image applies pending migrations when it boots. Back up
  before each deploy.

## 9. Store compliance

- **Account deletion:** Apple (Guideline 5.1.1(v)) requires in-app
  account deletion. Google Play requires in-app deletion **and** a public web
  URL where users can request deletion, entered in the Data safety form (still
  to publish, e.g. a support form; there is no unauthenticated deletion RPC).
  `requestAccountDeletion` now queues a real job (`AccountDeletionService`,
  run by the `fieldnote-outbox` future call within about a minute):
  - Refused with `deletion_blocked_checked_in`, `deletion_blocked_open_campaign`,
    `deletion_blocked_refund_pending` or `deletion_blocked_payment_pending`
    while an obligation is open. Joined-but-not-checked-in places are left
    automatically.
  - Deletes availability, current consent, invitations, private evidence
    photos, outbox and rate-limit rows, then revokes all refresh tokens and
    deletes the Serverpod auth user (cascading to the email login, sessions
    and auth profile) and broadcasts the revocation.
  - Anonymises under a random id stored nowhere else: profile ("Deleted
    user"), the volunteer's evidence text, consent history (kept as the legal
    record), audit events, participations, sponsorships (message cleared),
    refunds (via their sponsorship) and test payouts (kept for accounting).
  - `getAccountDeletionStatus` reports `pending/processing/completed/failed`.
    Issued access tokens stay cryptographically valid until they expire, but
    every FieldNote RPC then fails with `profile_required`.
  - Backups still contain the old data until they age out; state the backup
    retention period in the Privacy Policy.
- **Privacy disclosures:** Data safety (Play) and App Privacy (App Store) must
  match the Privacy Policy. That covers email, name, phone (sponsors), precise location,
  photos, audio (sent for transcription, not retained), payment info (handled by
  Razorpay) and user content.
- Permission strings: camera, photo library, location when in use, microphone and speech
  recognition are in `Info.plist` and must stay accurate.
- Crash reporting is intentionally not included in this release .

## 10. Branding and icons

Display names are set to "FieldNote" on Android, iOS and web. The launcher
icon (a lime map pin holding a field note on brand forest green) is generated
for Android (legacy + adaptive), iOS, web (favicon, PWA and maskable icons,
manifest colours) and macOS.

- Source artwork: `fieldnotes_flutter/assets/branding/icon.svg`.
- PNGs (`icon.png` full-bleed 1024px, `icon_foreground.png` transparent
  adaptive foreground, `icon_macos.png` rounded tile) are rendered from the
  same geometry by `flutter test tool/render_icon_test.dart` (no SVG tool
  needed).
- Config: the `flutter_launcher_icons:` block in `fieldnotes_flutter/pubspec.yaml`
  (adaptive background `#1D4B3B`, `remove_alpha_ios: true`). Regenerate with
  `dart run flutter_launcher_icons`.
- After regenerating, check `ios/Runner.xcodeproj/project.pbxproj`:
  flutter_launcher_icons 0.14.x rewrites
  `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES` to
  `= AppIcon`; set it back to `YES`.

Still to do: the native launch/splash screens use the template background.

## 11. Localization and dark mode

The app follows the system theme (`ThemeMode.system`). Colours come from the
`FieldnoteColorsTheme` extension in `lib/ui/core/fieldnote_theme.dart`
(`context.fieldnoteColors`); add new colours there with light and dark values
rather than hardcoding `Colors.white` or `FieldnoteColors.*`. Google Map tiles
keep Google's default light style, so map overlays (geofence rings, routes,
legend dots) keep the light brand colours on purpose.

Strings use Flutter gen-l10n (`fieldnotes_flutter/l10n.yaml`, ARB files in
`lib/l10n/`, generated `AppLocalizations`, accessed via `context.l10n`).
Supported locales: English (`en`, complete template), Hindi (`hi`) and Tamil
(`ta`). Material/Cupertino framework strings are translated by Flutter.
`app_hi.arb` and `app_ta.arb` cover short UI labels only and **need
native-speaker review before release**; any missing key falls back to English,
and `build/l10n_untranslated.json` lists them after each build. See
`lib/l10n/README.md`.

Migrated to ARB so far: sign-in, app shell/navigation, onboarding, Trust
(consent gate, Trust & safety, account deletion, the data-export screen),
profile and `lib/ui/core/legal.dart`. Dates and numbers in those files are
formatted with `intl` in the current locale.

Also migrated: every volunteer screen (`lib/ui/features/volunteer/**`:
matches, map, invitations, My work, check-in, evidence sheet, availability,
history, shared campaign links, the area map), the core maps
(`fieldnote_map.dart`, `location_picker.dart`, `in_app_maps.dart`; route
step instructions come from Google and stay in Google's language) and the
data-export record text. Pure volunteer helpers (`participationDisplay`,
`reviewStateLabel`, `checkInOpensLabel`, `accuracyMessage`,
`availabilityWindowProblem`, `distanceLabel`) take an optional
`AppLocalizations` and default to English. `widgets.dart` has no literals of
its own. Match reasons and integrity reasons are written by the server and
stay English.

Errors: `lib/ui/core/error_messages.dart` maps every error to a `UserError`
(kind, server `code`, `retryAfterSeconds`, server text, location issue).
`userMessageFor(error, {fallback})` keeps returning English for view models
(which compare it with `sessionExpiredMessage`/`offlineMessage`);
`userMessageFor(error, fallback: …, context: context)` or
`UserError.from(error).messageIn(l10n)` word it in the current locale. In
English the server's text wins; in other locales known codes (`rate_limited`,
`deletion_blocked_*`, `campaign_*`, `payouts_*`, `invalid_*`,
`input_too_long`, `client_request_id_reused`, `duplicate_payment_request`,
`forbidden`, `upload_failed`, location issues, offline, session expired) use
the `coreError…` keys and unknown codes fall back to the server text.
`localizeStoredMessage(context, message)` re-words a stored
`sessionExpiredMessage`/`offlineMessage`.

Data export PDF: labels and dates follow the app locale for English. The
`pdf` package shapes only Latin and Arabic text, so Hindi and Tamil labels
would be drawn with misplaced vowel signs and no conjuncts; the PDF
therefore keeps English labels for `hi`/`ta`, while the on-screen records
are localized. User-entered text is embedded with Noto Sans Tamil and,
when bundled, Noto Sans Devanagari (`assets/fonts/NotoSansDevanagari.ttf`,
SIL OFL 1.1, licence in `NotoSansDevanagari-OFL.txt`). The font is loaded
optionally and is only included once it is listed under `flutter: assets:`
in `pubspec.yaml`.

Not yet migrated (follow-up):

| Area                           | Files                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sponsor                        | `lib/ui/features/sponsor/sponsor_views.dart` (largest), `campaign_readiness_view.dart`, `campaign_pin_picker.dart`, `campaign_volunteer_reach_view.dart`, `payout_view.dart`, `campaign_map_view.dart`, `sponsor_checkout.dart`, `payment_history_view.dart`, `campaign_post_dialog.dart`, `sponsor_formatting.dart`                                                                                                                      |
| View-model messages            | `fieldnote_view_model.dart` stores English `userMessageFor(error)` strings (`errorMessage`, `lastError`, `impactErrors`). To localize them, store the `UserError` (or the error) and word it in the view with `messageIn(context.l10n)`; until then views can pass stored text through `localizeStoredMessage`. The `accountDeletionSignInMessage`/`sessionExpiredMessage` notices on the sign-in screen are English for the same reason. |
| Volunteer leftovers            | The saved-area labels`Chosen map area`/`Current GPS area` in `volunteer_views.dart` are stored as the availability `locationLabel` and stay English. `formatMinutes` keeps 24-hour `HH:mm`.                                                                                                                                                                                                                                                       |
| Data export PDF in Hindi/Tamil | Needs a PDF renderer with Indic shaping (see above); labels stay English until then.                                                                                                                                                                                                                                                                                                                                                                          |

How to migrate a file:

1. Add `import '<relative>/l10n/l10n.dart';` and read `final l10n = context.l10n;` in `build` (or in the helper that has a context).
2. Move each user-facing literal into `lib/l10n/app_en.arb` with a prefixed key (`sponsor…`, `volunteer…`); use `{placeholders}` for values and ICU `plural` for counts. Never put stored values (sponsor types, interest/skill tags, statuses sent to the server) in ARB; map them to labels instead.
3. Replace `DateFormat('…')`/`NumberFormat` without a locale with locale-aware ones, e.g. `DateFormat.yMMMd(context.localeTag)`. Keep money formatting in sync with the integer-paise rules in `lib/ui/features/sponsor/sponsor_formatting.dart`.
4. Run `flutter gen-l10n` (or `flutter pub get`), `flutter analyze` and `flutter test`. Tests that use `find.text` with English keep working because `context.l10n` falls back to English when no delegate is present.
5. Add translations to `app_hi.arb` / `app_ta.arb` only when they have been reviewed.

---

## Release checklist

- [ ] All required passwords set as `SERVERPOD_PASSWORD_*` env vars; dev values rotated
- [ ] `SERVERPOD_*_PUBLIC_HOST` and database/Redis env vars set; no `examplepod.com` host in effect
- [ ] Image built from repo root; `docker run --rm --entrypoint ls fieldnote-server config` shows no `passwords.yaml`
- [ ] Android: `key.properties` (or CI env) with real `fieldnote.applicationId`, `fieldnote.linkHost` and upload key; Play App Signing enrolled
- [ ] iOS: `AppIdentity.local.xcconfig` with real bundle ID, link host and team; Associated Domains enabled
- [ ] `FIELDNOTE_ANDROID_PACKAGE`, `FIELDNOTE_ANDROID_SHA256_CERT_FINGERPRINTS` and `FIELDNOTE_IOS_APP_ID` set; `https://<link-host>/.well-known/assetlinks.json` and `/apple-app-site-association` return 200
- [ ] `SERVERPOD_ALLOWED_ORIGINS` set to the web origin(s); Redis host and password set
- [ ] App built with `SERVER_URL` and `CAMPAIGN_SHARE_BASE_URL` dart-defines
- [ ] Privacy Policy and Terms reviewed by a lawyer, placeholders filled, versions match the endpoint constants, `/legal/privacy` and `/legal/terms` linked in app and store listings
- [ ] Redis enabled for multi-instance deployments
- [ ] SMTP sender verified (SPF/DKIM/DMARC); codes not logged
- [ ] Razorpay live keys, webhook URL `/webhooks/razorpay` and `razorpayWebhookSecret` configured; payment and refund flows verified on staging
- [ ] Manual creator-payout process (section 7, "Payouts") owned by operations; migration applied and `FIELDNOTE_PAYOUT_OPERATOR_IDS` configured for trusted operators
- [ ] Migration `20261002062415263-money-paise-idempotency` reviewed: it **drops** six unused tables (`fieldnote_asset`, `fieldnote_observation`, `fieldnote_observation_media`, `fieldnote_follow_up_task`, `fieldnote_organization_member`, `fieldnote_review_decision`); back up first
- [ ] Database backups and PITR on; restore rehearsed
- [ ] Account deletion exercised end to end on staging; Play web deletion URL published
- [ ] SMTP verified for notifications (send a test cancel on staging)
- [X] Launcher icons generated (section 10)
- [ ] Hindi and Tamil strings reviewed by native speakers; sponsor/volunteer screens localized (section 11)
