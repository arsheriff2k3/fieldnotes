# FieldNote external services and secrets

This checklist separates the credentials required for a local end-to-end test from the additional infrastructure needed for a public launch. Never place server secrets in Flutter, `--dart-define`, source control, screenshots, or chat messages.

## Immediate credentials for the finished integration

Add these values manually to `fieldnotes_server/config/passwords.yaml` under `development`. That file is already ignored by Git.

```yaml
development:
  # Existing Serverpod database/auth values remain here.

  # Hosted campaign and multimodal evidence AI.
  geminiApiKey: 'YOUR_GEMINI_API_KEY'
  geminiModel: 'gemini-3.8-flash'
  # Hold-to-speak dictation. Optional; defaults to gemini-3.5-transcribe.
  geminiTranscriptionModel: 'gemini-3.5-transcribe'

  # Razorpay Test Mode. The secret is server-only. The key ID may be returned
  # to the authenticated Flutter checkout after the server creates an order.
  razorpayKeyId: 'rzp_test_...'
  razorpayKeySecret: 'YOUR_RAZORPAY_TEST_SECRET'
  # Secret entered when creating the webhook in the Razorpay Dashboard.
  # Verifies X-Razorpay-Signature on POST /webhooks/razorpay. Optional
  # locally; without it the webhook answers 503 and the sweep still
  # reconciles payments by polling Razorpay.
  razorpayWebhookSecret: 'YOUR_RAZORPAY_WEBHOOK_SECRET'

  # Google Maps Platform web services: Places, Geocoding, and Routes. This key
  # must NOT be the same restricted key the Flutter app renders tiles with.
  googleMapsApiKey: 'YOUR_GOOGLE_MAPS_SERVER_KEY'

  # Email delivery for signup verification, password reset and
  # transactional notifications (cancellations, invites, receipts).
  smtpUsername: 'YOUR_SENDING_GMAIL_ADDRESS'
  smtpAppPassword: 'YOUR_GOOGLE_APP_PASSWORD'
  # Optional, notifications only: use another STARTTLS provider than Gmail.
  # smtpHost: 'smtp.example.com'
  # smtpPort: '587'
```

Do not replace the existing database, email pepper, JWT, refresh-token, or service-secret entries.

If you prefer shell environment variables instead of editing YAML, Serverpod maps custom passwords using this exact prefix:

```bash
export SERVERPOD_PASSWORD_geminiApiKey='...'
export SERVERPOD_PASSWORD_geminiModel='gemini-3.8-flash'
export SERVERPOD_PASSWORD_geminiTranscriptionModel='gemini-3.5-transcribe'
export SERVERPOD_PASSWORD_razorpayKeyId='rzp_test_...'
export SERVERPOD_PASSWORD_razorpayKeySecret='...'
export SERVERPOD_PASSWORD_razorpayWebhookSecret='...'
export SERVERPOD_PASSWORD_googleMapsApiKey='...'
export SERVERPOD_PASSWORD_smtpUsername='sender@gmail.com'
export SERVERPOD_PASSWORD_smtpAppPassword='...'
```

Set these in the same terminal that runs `serverpod start`. Do not add them to a committed shell script.

### Local `.env` option

Serverpod reads the variables above but does not automatically load a `.env` file. The repository includes a safe template and loader script:

```bash
cd /Users/ryan/Desktop/Project/serverpod/fieldnotes
cp .env.example .env
```

Edit `.env`, replace the credential placeholders, and start locally with:

```bash
./start-local.sh
```

The real `.env` is ignored by Git. Keep the `SERVERPOD_PASSWORD_` prefixes unchanged; Serverpod strips that prefix when exposing the values through its password API.

### Signup and password-reset email

FieldNote sends Serverpod's existing signup and password-reset codes from the
Gmail address in `smtpUsername`. Put a Google App Password in
`smtpAppPassword`; the normal Google account password will not work. Google
requires 2-Step Verification to create an App Password. Configure both values
in the server's private `development` passwords or in `.env`, then restart the
user-owned `serverpod start` process so it reads them. The app does not need a
new APK. If email delivery fails, signup reports an error and the server logs
the SMTP failure without printing the verification code. Password-reset
requests retain their account-enumeration protection and log delivery failures
only on the server. Normal email/password sign-in does not send a code.

### Transactional email

The same SMTP passwords drive `NotificationService` (see
`docs/DEPLOYMENT.md` section 6). Emails are queued in
`fieldnote_notification_outbox` and delivered by the one-minute
`fieldnote-outbox` future call. Without SMTP the rows are marked `skipped`.
Users can turn notifications off in their profile
(`setEmailNotifications`).

### Gemini

Required:

- A Google AI Studio or Gemini API project.
- A Gemini API key with Generative Language API access and available quota.
- Default model: `gemini-3.8-flash`, a stable multimodal model with Structured Outputs.

The key remains on the Serverpod server. The intended integration uses:

- `POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`
- structured JSON schemas for campaign proposals and evidence extraction;
- the volunteer evidence photograph plus the original note for multimodal extraction;
- no AI fallback for campaign drafting; evidence summaries fall back to a deterministic, volunteer-confirmed summary (`StructuredSummaryService.manualCompletionProposal`) when no key is set or the provider fails.

Restrict the key to the Generative Language API and the server's IP/application restrictions when available. Configure quota and billing alerts before public testing.

### Razorpay

Required for manual testing:

- Razorpay account with **Test Mode** enabled.
- Test Key ID beginning with `rzp_test_`.
- Matching Test Key Secret.
- Optional locally, required for a public deployment: a webhook secret stored as `razorpayWebhookSecret`.

The server must create the Razorpay Order. Flutter receives only the Key ID and Order ID, opens checkout, and returns payment ID/order ID/signature to Serverpod. Serverpod verifies the HMAC-SHA256 signature before recording sponsorship. Never put `razorpayKeySecret` in Flutter.

For local USB testing, Razorpay Checkout returns directly to the app and Serverpod verifies the signature.

#### Webhook

Create a webhook in the Razorpay Dashboard (Settings → Webhooks) pointing at the **web server** host:

```
POST https://<web-server-host>/webhooks/razorpay
```

Subscribe to `payment.captured`, `order.paid`, `payment.failed`, `refund.processed`, and `refund.failed`. Store the secret you type there as the `razorpayWebhookSecret` password. The server checks `X-Razorpay-Signature` (hex HMAC-SHA256 of the raw body) with a constant-time compare, de-duplicates deliveries by `X-Razorpay-Event-Id` in `fieldnote_payment_webhook_event`, and credits payments through the same locked path as checkout verification. Bad signatures get `401`, a missing secret gets `503`, and a processing error gets `500` so Razorpay retries.

#### Reconciliation and refunds

The `campaign-readiness-sweep` future call runs every 5 minutes and needs only `razorpayKeyId`/`razorpayKeySecret`:

- Unpaid orders older than 5 minutes are checked with `GET /v1/orders/{id}/payments`. A captured payment is credited; an order with no payment after 30 minutes is marked `expired` and stops reserving campaign balance.
- Refunds are queued when a campaign is cancelled or expires, and for any captured payment that could not be credited (`verified_uncredited`). The worker calls `POST /v1/payments/{id}/refund` with only the documented body fields: `amount` (paise), `speed: normal`, receipt `fn_refund_<rowId>` and note `fieldnote_refund_id`. No idempotency header is sent, because Razorpay documents none for this API. Before any retry, the worker lists `GET /v1/payments/{id}/refunds` and adopts a non-failed refund that carries that receipt or note, so a lost response never refunds twice. Failures retry with exponential backoff, up to 6 attempts.
- When a refund of a credited payment is processed (by the worker or the `refund.processed` webhook), its amount comes off the campaign's `sponsoredAmountPaise` and is added to `refundedAmountPaise`. This happens once per refund row (`fundingReversedAt`), under the campaign row lock. Uncredited captures never counted toward the campaign, so their refunds leave the funded amount unchanged.
- Creator payouts are never sent through Razorpay (no RazorpayX/Route integration). See "Payouts" in `DEPLOYMENT.md`.
- With `rzp_test_` keys every refund runs in Razorpay Test Mode and moves no real money. Refund rows record `testMode`.

### Google Maps Platform

FieldNote keeps all public client keys in one local `.env.maps` file, but uses
**separate restricted keys per platform**. The private server key stays in
Serverpod passwords and must never be placed in the Flutter environment file.

| Key | Lives in | Used for | Restrict by |
| --- | --- | --- | --- |
| Server key | `googleMapsApiKey` Serverpod password | Places Autocomplete, Place Details, Geocoding, Routes | API restriction + server IP |
| Client keys | `fieldnotes_flutter/.env.maps` | Rendering map tiles only | Android SHA-1 + package, iOS bundle ID, web HTTP referrer |

Enable these APIs on the Cloud project: **Maps SDK for Android**, **Maps SDK for iOS**, **Maps JavaScript API**, **Places API (New)**, **Geocoding API**, **Routes API**.

Create the local environment file once:

```bash
cp fieldnotes_flutter/.env.maps.example fieldnotes_flutter/.env.maps
```

Then populate the three values in `fieldnotes_flutter/.env.maps`:

```dotenv
GOOGLE_MAPS_ANDROID_API_KEY=YOUR_ANDROID_RESTRICTED_KEY
GOOGLE_MAPS_IOS_API_KEY=YOUR_IOS_RESTRICTED_KEY
GOOGLE_MAPS_WEB_API_KEY=YOUR_WEB_REFERRER_RESTRICTED_KEY
```

Android Gradle, iOS Xcode, and Flutter all consume this file automatically.
Rebuild the application after changing a key. The file is git-ignored; only
`.env.maps.example` is committed.

`.env.maps` starts with empty keys on purpose. **Nothing in the app requires Maps to work.** With no key for the current platform:

- every map renders a fallback panel carrying the same coordinates, distance, and accuracy text the app showed before Maps existed;
- the sponsor place-search field is hidden, and pins are set by dragging or by device GPS;
- campaign matching keeps its original straight-line distance score.

Billing notes. Map loads from the Android and iOS SDKs are not billed per load; Maps JavaScript, Static Maps, Places, Geocoding, and Routes are billed per call against a monthly free allotment. **Verify current per-SKU rates before enabling billing — Google restructured this pricing in 2025.** The server already limits its own spend: Places autocomplete is debounced at 350 ms, reverse geocoding fires only when a pin settles, and the Routes distance matrix is cached for 30 minutes per rounded origin/destination pair and capped at 100 destinations per call.

Two deliberate boundaries:

- **Geofence check-in never calls Google.** `checkIn` decides admission with the server's own haversine maths, so a network failure or an expired key can never let an off-site volunteer check in, nor block an on-site one.
- **Sponsors never see individual volunteer locations.** `previewCampaignReach` returns counts plus coverage buckets rounded to roughly a kilometre, and suppresses any bucket holding fewer than three volunteers.

## No key required

These features already use device/platform functionality and require no external API account:

- GPS location and geofence: `geolocator`
- camera/gallery evidence: `image_picker`
- speech recognition: `speech_to_text`
- local Serverpod PostgreSQL
- local Serverpod private object storage
- transactional notifications are skipped (logged, never failing the action) when SMTP is not configured

The volunteer work screen includes a Live Location Check panel that visibly streams coordinates, accuracy, freshness, the platform mock-location flag, and campaign distance. Streaming stays on that screen; only the check-in snapshot is sent to Serverpod. The debug GPS simulation remains clearly labeled. Server checks coordinate bounds, freshness, accuracy, the mock flag, geofence distance, and movement continuity. These are meaningful anti-spoof signals for the demo, but mobile GPS alone cannot guarantee physical presence; a public high-risk deployment should also add Android Play Integrity / Apple App Attest and server-side device-risk telemetry.

## Flutter and Dart dependencies

Already installed:

```yaml
geolocator: ^14.0.2
image_picker: ^1.2.1
speech_to_text: ^7.3.0
serverpod_flutter: 4.0.0
serverpod_auth_idp_flutter: 4.0.0
```

Required for Razorpay checkout:

```yaml
razorpay_flutter: ^1.4.7
```

Required for the map surfaces:

```yaml
google_maps_flutter: ^2.9.0
url_launcher: ^6.3.0
```

Installed on the Serverpod side for payment signature verification:

```yaml
crypto: ^3.0.6
```

Gemini is called from the server with Dart's HTTP client, so no unofficial Gemini client package is required.

## Runtime configuration

Local USB test using the existing Android APK/network setup:

```bash
serverpod start
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=SERVER_URL=http://localhost:8080/
```

Wi-Fi device test:

```bash
flutter run --dart-define=SERVER_URL=http://YOUR_LAPTOP_LAN_IP:8080/
```

For Wi-Fi testing, update the development Serverpod `publicHost` to the same LAN IP so private upload URLs are reachable from the phone.

## Additional requirements for a public launch

These are not solved by API keys alone:

- Real domain names for API, web, and Insights services.
- TLS/HTTPS certificates and a production deployment target.
- Managed PostgreSQL credentials, backups, and recovery testing.
- Production private object storage and retention policy.
- Production email delivery or Serverpod Cloud email configuration.
- Razorpay account activation/KYC, live keys, capture settings, settlements, refunds, and production webhook URL.
- Android release signing keystore and Play Console account.
- Apple Developer account, bundle ID, signing certificates, and App Store Connect configuration for iOS.
- Privacy policy, terms, consent copy, location/photo retention rules, moderation, support, incident response, rate limits, monitoring, and alerting.
- Removal of debug signing, demo GPS, demo campaigns, and simulated sponsorship language from the production flavor.

## Manual handoff

Prepare the Gemini API key and Razorpay **Test Mode** Key ID/Secret locally. Do not send secret values through chat. Start Serverpod from that same shell, install the APK, and use Razorpay's test payment details in Checkout. The Trust tab records order creation and server signature verification.
