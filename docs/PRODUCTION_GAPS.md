# FieldNote production MVP gap audit

Audit date: 2026-10-01. Scope: `fieldnotes_server`, `fieldnotes_flutter`, config, CI, and platform setup.

## Remediation status (2026-10-02)

**Verified:** server `dart analyze` clean, `dart test` 85/85; app `flutter analyze` clean, `flutter test` 51/51. Nothing has been run against a live server or on a device yet.

**Migrations:**
- `20261001084803764-money-lifecycle`
- `20261001143105843-compliance-notifications`: hand-edited `migration.sql` to backfill `shareSlug`.

**Fixed:**
- **P0:** P0-1 through P0-11.
  - P0-8 now has a non-AI summary fallback and a "write it yourself" mode.
  - P0-7 has drafts only (`/legal/privacy`, `/legal/terms`), pending legal review.
  - P0-10 and P0-11 are now driven by env vars and build settings; you supply the values.
- **Sponsor:** S-1 through S-10.
- **Volunteer:** V-1 through V-10.
  - V-9: the offline outbox was deleted. Offline capture is not part of the MVP.
- **Server:** A-1 through A-3 and A-5 through A-10.
- **Trust:** T-1 through T-4.
- **Platform:** R-1 through R-6. R-7 only has logging hooks; you chose no crash-reporting vendor.
- **P2:** most items, including authz on the stream, posts and readiness; length caps; indexes; pagination; slug share links; `/.well-known/*`; timezone matching; "help today" expiry; full-campaign handling; form fixes; and removal of the Greeting template.

**Still open:**
- **Data:** A-4, money is still stored as `double` (all maths uses integer paise).
- **Payments:**
  - Refunds don't reduce `sponsoredAmount`.
  - Payouts are still a manual test simulation.
  - Publishing has no idempotency key.
  - The Razorpay refund idempotency header name needs checking against Razorpay's docs.
- **Database:** the six unused tables haven't been dropped.
- **App:**
  - No dark theme, no localization, stock icons.
  - Timezones use the UTC offset only, with no DST rules.
- **Not reviewed:** `lib/src/auth/verification_email_sender.dart` (permission settings blocked reading it).

**Before release you must:**
1. Set the app ID, signing keys and link host (`android/key.properties`, `ios/Flutter/AppIdentity.local.xcconfig`).
2. Set the `SERVERPOD_*` hosts, Redis, allowed origins and `FIELDNOTE_*` variables.
3. Set the passwords: Razorpay live keys, `razorpayWebhookSecret`, SMTP, AI keys.
4. Register the webhook URL `/webhooks/razorpay`.
5. Have the legal pages reviewed and fill in `[CONTACT_EMAIL]` and `[LEGAL_ENTITY]`.

`docs/DEPLOYMENT.md` lists each of these.

**Severity**
- **P0**: blocks launch (lost money, legal or store-compliance risk, security).
- **P1**: an incomplete flow or significant bug.
- **P2**: polish, hardening, or tech debt.

**Path abbreviations**
- `EP` = `fieldnotes_server/lib/src/fieldnotes/fieldnote_endpoint.dart`
- `FV` = `fieldnotes_flutter/lib/ui/features/volunteer/volunteer_views.dart`
- `FS` = `fieldnotes_flutter/lib/ui/features/sponsor/sponsor_views.dart`

**Not audited:** permission settings blocked `fieldnotes_server/lib/src/auth/` and `config/passwords.yaml`, so they weren't read. Someone still needs to check whether the email sender also logs codes in plaintext.

---

## 1. User flows

### Sponsor

| # | Step | Client | Server | Status |
|---|---|---|---|---|
| 1 | Pick a role, then sign up | `screens/sign_in_screen.dart`, `onboarding_view.dart:452` | Serverpod auth | Done |
| 2 | Onboarding and consent | `onboarding_view.dart:260` | `completeSponsorProfile`, `acceptLegalConsent` | Done |
| 3 | Create a campaign from a written or dictated brief (AI) | `FS:1045`, `FS:840/916` | `proposeCampaign` EP:619, `transcribeDictation` | Done |
| 4 | Edit the draft | `FS:1155`, `showProposalFormDialog` FS:2135 | — | Partial: data is lost on a tap outside |
| 5 | Pin the location | `CampaignPinPicker`, `FS:1067` | — | Done |
| 6 | Publish | `FS:1169` | `createCampaignFromProposal` EP:704 | Partial: no idempotency, weak server validation |
| 7 | Pay with Razorpay | `FS:209`, `razorpay_checkout_*` | `createRazorpayOrder` EP:1974, `verifyRazorpayPayment` EP:2078 | **Broken edge cases** (see P0) |
| 8 | Monitor impact and evidence | `SponsorImpactView` FS:1551 | `getImpact`, `watchCampaign` | Partial |
| 9 | Revise, postpone or cancel | `campaign_readiness_view.dart` | EP:829 / 891 / 942 | Partial |
| 10 | Payouts and refunds | `payout_view.dart` | EP:2242 / 2263, `TestRefund` | Test mode only; no real refunds |
| 11 | Close the campaign | — | — | **Not built** |
| 12 | Review or reject evidence | — | — | **Not built** |
| 13 | Payment history | — | — | **Not built** |
| 14 | Post campaign updates | — | `createCampaignPost` EP:2972 | Server only; no UI |

### Volunteer

| # | Step | Client | Server | Status |
|---|---|---|---|---|
| 1 | Pick a role, then sign up | `sign_in_screen.dart:47` | Serverpod auth | Done |
| 2 | Onboarding (skills, interests, days, GPS area) | `onboarding_view.dart:189, 319-328` | `completeVolunteerProfile` EP:378 | Partial: time window hardcoded |
| 3 | Consent | `LegalConsentGate` (`app_shell.dart:119`) | `acceptLegalConsent` | Done |
| 4 | Edit availability | `FV:1748` | `updateAvailability` EP:482 | Partial |
| 5 | Matches (List, Map, Invites) | `FV:48` | `getCampaignMatches` EP:2344 | Partial: timezone bug, full campaigns shown |
| 6 | Shared campaign link | `main.dart:58`, `app_shell.dart:48`, `shared_campaign_view.dart` | `getSharedCampaign` EP:797 | Partial |
| 7 | Join | `FV:338` | `joinCampaign` EP:2440 | Done (row lock, idempotent) |
| 8 | Reconfirm after the sponsor changes the event | `FV:708, 800` | EP:1001 | Done |
| 9 | Travel and route | `ui/core/in_app_maps.dart`, `FV:1037` | `getTravelRoute` EP:1356 | Done |
| 10 | Check in (200 m geofence) | `FV:637, 672` | `checkIn` EP:2542 | Partial: check-in window not shown |
| 11 | Photo, note, AI summary | `CompletionEvidenceSheet` FV:1246 | `analyzeCompletion` EP:2655 | **Hard dependency on an AI key** |
| 12 | Submit completion | `FV:1338`, `fieldnote_repository.dart:319` | `completeParticipation` EP:2765 | Partial: missing checks |
| 13 | Leave a campaign | — | — | **Not built** |
| 14 | History, impact, earnings | — | — | **Not built** |
| 15 | Offline capture | `local_outbox_service.dart` (never used) | — | **Dead code** |

### Cross-cutting

| Flow | Status |
|---|---|
| Email verification and password reset | Sent by SMTP (`server.dart:30-62`) |
| Sign out | Partial: doesn't clear local state |
| Session expiry | Not handled explicitly |
| Trust area: consent, export, deletion | Export works; **deletion is fake**; consent can't be withdrawn |

---

## 2. P0: blocks launch

| ID | Area | Gap | Evidence | Fix |
|---|---|---|---|---|
| P0-1 | Payments | **Web: a failed card attempt followed by a successful retry loses the payment.** `payment.failed` completes the future. When the retry succeeds, `_succeed` returns early because the future is already completed, so the money is captured but never verified or credited. | `razorpay_checkout_web.dart:65-70`, `:136` | Keep the checkout open after `payment.failed`; only complete on success or dismiss. Back this with reconciliation (P0-2). |
| P0-2 | Payments | **No webhook and no reconciliation.** If the app is killed, the network drops or the tab closes between checkout and verify, the sponsorship stays `created` forever. | EP:2078; `lib/server.dart:76-95` (no webhook route) | Add a Razorpay webhook route: verify `X-Razorpay-Signature`, dedupe by event ID, credit with the existing locked service. Add a sweep that fetches order status for stale `created` orders. |
| P0-3 | Payments | **Refunds are never executed.** `TestRefund` rows are marked `refund_due_test` and nothing processes them. | `test_refund.spy.yaml`, EP:979 | Build a refund worker that calls Razorpay `/payments/{id}/refund` and tracks status. |
| P0-4 | Payments | **Expired campaigns keep the money.** Cancelling creates refund rows; expiring creates none. Payouts need `confirmed`/`completed`, so the funds are stranded. | EP:1109-1110 vs EP:972-983; EP:2289 | Create refunds on the expired transition too. |
| P0-5 | Lifecycle | **Campaigns never end.** `CampaignStatus.completed` and `draft` are never assigned, and `confirmed` is terminal. No-shows and incomplete participations are never resolved. | EP:746, EP:1098-1107, EP:2290 | In the sweep, after `endsAt`: move the campaign to `completed`, mark no-shows and incompletes, and trigger payouts or refunds. |
| P0-6 | Compliance | **Account deletion is fake.** `requestAccountDeletion` only writes an audit row. There's no job, no auth-user removal and no storage purge. The App Store and Play Store require real deletion. | EP:329-339 | Add a deletion future call. It anonymises shared rows, deletes the profile, availability, consent, evidence blobs and auth user, then revokes sessions. |
| P0-7 | Compliance | **No Privacy Policy or Terms text**, only version strings. | `trust_center_view.dart:102-105`, `onboarding_view.dart:800` | Host the documents and link them from signup, onboarding, the consent gate and the Trust area. |
| P0-8 | Volunteer | **No volunteer can finish a campaign without a Gemini or Groq key.** The fallback service named in AGENTS.md doesn't exist, and the client needs an AI proposal to submit. | EP:2685-2691, FV:1339 | Add a manual-summary path, and/or a deterministic fallback when no AI key is set. |
| P0-9 | Security | **The Docker image would ship `config/passwords.yaml`** (Gemini, Razorpay, SMTP and JWT secrets). There is no `.dockerignore`. | `fieldnotes_server/Dockerfile:10,43` | Add a `.dockerignore` for `passwords.yaml` and `.env*`; inject secrets as `SERVERPOD_PASSWORD_*` env vars. |
| P0-10 | Release | `production.yaml` and `staging.yaml` still have template hosts (`*.examplepod.com`). | `config/production.yaml:10,17,24,33` | Set the real API, web and DB hosts. |
| P0-11 | Release | Android uses package `com.example.fieldnotes_flutter` and signs release builds with the debug key. The iOS bundle is `com.example.fieldnotesFlutter`. | `android/app/build.gradle.kts:18,29,47`, `ios/Runner.xcodeproj/project.pbxproj:386` | Set real app IDs; add a release keystore through `key.properties`. |

---

## 3. P1: incomplete flows and major bugs

### Sponsor

| ID | Gap | Evidence | Fix |
|---|---|---|---|
| S-1 | The payment dialog can be dismissed while the payment is being verified, including with Android back. The UI then shows no success and doesn't refresh. | FS:235 | `barrierDismissible: false` plus `PopScope` while verifying. |
| S-2 | "Payment needs review" (`verified_uncredited`) and failed sponsorships are never listed. There is no payment history. | FS:1562; `payment_credit_service.dart:96-110` | Add a payment history screen; auto-refund or queue uncredited payments. |
| S-3 | A funded campaign disappears from the Impact view once it starts, is cancelled or expires. That is exactly when evidence arrives. | `fieldnote_view_model.dart:115-118`, FS:1560, EP:785-791 | Add a `listMyCampaigns` endpoint (created or funded, any status). |
| S-4 | Cancelled and expired campaigns show as "Planning". | FS:563-570 | Add those cases to the status switch. |
| S-5 | Cancelling after a simulated payout creates both a payout and a refund (double counting). The payout screen reads a stale `readinessState`. | EP:942-983, `payout_view.dart:118,161` | Block cancellation or refunds when payouts exist; reload the campaign. |
| S-6 | Sponsors can't review or reject evidence. `ReviewDecision`/`ReviewState` models are never used. The evidence photo `FutureBuilder` spins forever on error, and its temporary URL is never refreshed. | FS:1801, FS:1843 | Add an approve/reject endpoint and UI, an error state, and URL refresh. |
| S-7 | Errors after login are hidden; `errorMessage` only renders when `profile == null`. One failed `impact()` call aborts the whole load. | `app_shell.dart:108`, `fieldnote_view_model.dart:120-124` | Show errors in a snackbar or banner; load impact per campaign with separate error handling. |
| S-8 | The live stream swallows errors, never reconnects, and only subscribes to the first campaign. | `fieldnote_view_model.dart:125-127, 274` | Reconnect with backoff; subscribe per campaign; show the subscribed state. |
| S-9 | `createCampaignPost` has no UI, yet volunteers read posts. | EP:2972, FV:551 | Add a "Post update" action. |
| S-10 | There is no UI for refunds, and `inviteCampaignVolunteersInArea` is unused. | — | Surface both or remove them. |

### Volunteer

| ID | Gap | Evidence | Fix |
|---|---|---|---|
| V-1 | Volunteers can't leave a campaign. Every participation counts toward capacity forever. | EP:2476 | Add `leaveCampaign`: free the seat, recompute readiness, broadcast. |
| V-2 | A cancelled campaign stays in My work with "Await event confirmation". | FV:906 | Show a cancelled state and hide the check-in actions. |
| V-3 | `completeParticipation` doesn't check the campaign status (cancelled), `endsAt`, or distance. | EP:2791-2802 | Validate state, time window and geofence. |
| V-4 | The availability time window is hardcoded to 07:00–13:00 and can't be edited. Afternoon campaigns lose the 40 availability points. | `onboarding_view.dart:327-328`, FV:1765-1766, EP:3361-3365 | Add a time-range picker. |
| V-5 | Matching uses the server's timezone (`toLocal()` / `DateTime.now()`). | EP:3346-3357, EP:1856 | Store the volunteer's IANA timezone and compare in it. |
| V-6 | Location error messages are replaced with generic text, and the volunteer screens have no "Open Settings" button. | FV:2093, FV:702, 1371, 1781, 1939; `device_location_service.dart:54-127` | Show the `LocationException` message; add an Open Settings action. |
| V-7 | The check-in window (30 minutes before start until the end) isn't shown. | EP:2576-2587, FV:896 | Show the window and disable the button outside it. |
| V-8 | Submitting needs a second fresh GPS fix (under 2 minutes old, better than 150 m accuracy), and fails generically indoors. | FV:1349 | Use the check-in fix within a grace period, or show a clear accuracy message. |
| V-9 | The offline outbox is dead code. If it were wired in as written, its one global key would replay one user's captures after another user logs in, and it keeps base64 photos in SharedPreferences. Closing the sheet loses the photo, note and draft. | `local_outbox_service.dart:37-38` | Wire it in with a per-user key and file storage, clear it on sign-out, or delete it. |
| V-10 | No volunteer history, impact or evidence view. `getEvidenceDownloadUrl` allows volunteers but they never call it. | EP:2896, EP:2917 | Add a "My impact" screen. |

### Server and security

| ID | Gap | Evidence | Fix |
|---|---|---|---|
| A-1 | A volunteer can overwrite their evidence photo after completing: the upload path is fixed and there's no status check. | EP:2751-2763, EP:3571 | Allow uploads only while `checkedIn`; use a unique path pinned in `CompletionEvidence`. |
| A-2 | `getCampaignVolunteerMap` returns the names of volunteers who haven't joined, with locations rounded to about 1 km. This breaks the k-anonymity rule. | EP:1604-1637 | Return aggregate buckets only for volunteers who haven't joined. |
| A-3 | No rate limiting on the billed AI, Maps and transcription calls, on order creation, or on auth. | Whole endpoint | Per-user quotas (Redis or DB counters). |
| A-4 | Money is stored as `double`. | `campaign.spy.yaml`, `sponsorship.spy.yaml` | Store integer paise. |
| A-5 | `createCampaignFromProposal` trusts the client: the goal can be 0, negative or NaN; the duration can be negative; capacity has no upper limit. | EP:723-761 | Validate ranges on the server. |
| A-6 | `_refreshDueCampaigns` runs on every list call, scanning all active campaigns with one transaction each. | EP:1042 | Leave it to the 5-minute sweep. |
| A-7 | Full-table scans: all `CompletionEvidence` and `TestRefund` rows are loaded and filtered in memory. | EP:228, EP:240, EP:2930 | Use `inSet` / `where` queries. |
| A-8 | Redis is off in production, so `session.messages` and live streams don't reach across instances. | `config/production.yaml` | Enable Redis. |
| A-9 | No push notifications or transactional email. "Do not travel" cancellations only appear inside the app. | EP:995, EP:1146 | Add FCM and email notifications for cancel, postpone, invite and confirm. |
| A-10 | `completeParticipation` isn't in a transaction; a race produces a raw unique-index error. | EP:2835-2859 | Wrap it in a transaction with `forUpdate` on the participation. |

### Auth and Trust

| ID | Gap | Evidence | Fix |
|---|---|---|---|
| T-1 | Sign out doesn't clear the pending role or local data, and there's no "sign out all devices". | `profile_view.dart:458` | Clear local services on sign-out; add `signOutAllDevices`. |
| T-2 | Users can't withdraw consent, and the client always sends `true,true,true`. | `fieldnote_repository.dart:274`, `profile_view.dart:684` | Add `withdrawConsent` and send the real checkbox values. |
| T-3 | Onboarding hardcodes the policy version, so it will drift from the server. | `onboarding_view.dart:800` vs EP:57-58 | Read it from `getTrustCenter`. |
| T-4 | The docs contradict themselves on whether email codes are logged or sent by SMTP. | `docs/SECRETS_AND_EXTERNAL_SERVICES.md:67-78` vs `:163`; `docs/IMPLEMENTATION_PLAN.md:76` | Fix the docs. |

### Platform and release

| ID | Gap | Evidence | Fix |
|---|---|---|---|
| R-1 | Cleartext HTTP is allowed in the main manifest (release builds too). | `android/app/src/main/AndroidManifest.xml:11` | Move it to the debug manifest or a network-security-config. |
| R-2 | A fresh clone won't build: `.env.maps` is a pubspec asset, but `.env.maps.example` is git-ignored. | `.gitignore:73`, `fieldnotes_flutter/pubspec.yaml:79` | Add `!**/.env.maps.example`. |
| R-3 | The public share page renders any campaign by sequential ID, including drafts and cancelled campaigns. | `campaign_share_route.dart:23` | Return 404 for non-public states; use random slugs. |
| R-4 | The share page hardcodes `package=com.example.fieldnotes_flutter` and serves an APK from the local build directory. | `campaign_share_route.dart:9,116`, `server.dart:83-95` | Parameterize the package name; use a store URL. |
| R-5 | No App Links or Universal Links, only the `fieldnote://` scheme. | `AndroidManifest.xml:43`, `campaign_link_service.dart:19,30` | Add `autoVerify` intent filters, `assetlinks.json` and an AASA file. |
| R-6 | CORS and cookie auth are commented out. | `production.yaml:71-79` | Enable `authCookie` and `allowedOrigins`. |
| R-7 | No crash reporting or error hooks (`FlutterError.onError`, `runZonedGuarded`). | `main.dart:14-25` | Add Sentry or Crashlytics and log shipping. |

---

## 4. P2: polish and hardening

### Sponsor
- Form data is lost on a tap outside (FS:2144). The revise dialog closes before validating (`campaign_readiness_view.dart:111-126`).
- "25,000" fails to parse (FS:2316). There's no cap on the goal, while a single payment is capped at ₹10,00,000 (EP:1981).
- A publish retried after a lost response creates a duplicate campaign (no idempotency key). A failed publish says "Could not generate the campaign." (FS:1204).
- The AI resolves relative dates like "this Saturday" in the server's timezone (EP:631).
- After publish, only a few fields can be edited (no title, location, capacity or checklist).
- The cancel dialog doesn't show how many volunteers have joined, and participations aren't updated (EP:942-999).
- Expired campaigns can be postponed back to life (EP:913). Revise and postpone are allowed after the start or after check-ins (EP:853, 911).
- Weak buttons:
  - "Open sponsor checkout" only switches tabs (`campaign_readiness_view.dart:343`).
  - "Copy volunteer invite" copies text with no link (`:195-199`).
  - The empty-state "Create" button leads to a tab that holds just another button (FS:147, FS:199).
- No pull-to-refresh on Impact (FS:1570).
- Parallel orders can oversubscribe a campaign (no lock on the remaining balance), and `created` orders never expire (EP:1988-2010).
- Payout simulation is allowed before any work happens (EP:2289).

### Volunteer
- Full campaigns still show a Join button (EP:3419). The list Join button isn't disabled while a request runs (FV:128).
- "I can help today" never expires (EP:3251, 3360).
- A saved or pinned area is labelled "Live GPS area selected" (FV:1563, 1659, 1693, 1953).
- The client's inside/outside chip counts the accuracy radius, but the server rejects any fix worse than 150 m, so a volunteer shown "inside" can still be rejected (FV:930, `location_integrity_service.dart:41`).
- A denied microphone shows "unavailable on device". There are no `onError`/`onStatus` handlers, so the mic can stay stuck on listening (FV:1271-1289).
- The note minimum is 5 characters in the client and 8 on the server (FV:1301 vs EP:2663).
- No upload progress indicator, and the photo is sent twice (once to the AI, once to storage).
- A shared link to a started campaign says "no longer open", even for a volunteer who joined it (EP:805). The link page shows the raw error object (`shared_campaign_view.dart:41`). A pending link is lost if the app is killed before sign-in.
- Nothing blocks joining two campaigns that overlap in time.
- Capacity counts stale unconfirmed joins (EP:2476).

### Server
- Any user can open the live stream for any campaign, and it broadcasts display names (EP:3018-3033, 2500).
- Any user can call `refreshCampaignReadiness` or `listCampaignPosts` on any campaign (EP:821, EP:3005).
- The "AI generated" flag is inferred from client text, and the confirmed summary isn't tied to the AI output (EP:761, 2769).
- Availability fields aren't validated (coordinates, weekday 1–7, minutes 0–1440), and empty weekdays are accepted (EP:3215-3261, 394).
- Free text and lists have no maximum length.
- Error messages expose the secret's config key name, and raw provider errors are saved in the user-visible audit log (EP:3613, 2038).
- Moderation is a few regexes (`content_moderation_service.dart`).
- N+1 queries and scans of every availability row (EP:1035, 2364, 1580, 1606, 1781, 1441).
- No pagination on any list endpoint.
- Missing indexes:
  - `campaign(status, startsAt)`
  - `campaign(createdBy)`
  - `audit_event(actorAuthUserId, occurredAt)`
  - `sponsorship(campaignId, paymentStatus)`
- One hardcoded organization with a fake creator UUID (EP:3465-3479).
- The Gemini model default is hardcoded (EP:3669), and the campaign model's default coordinates are Pune (`campaign.spy.yaml`).
- Six tables are never used:
  - `asset`
  - `observation`
  - `observation_media`
  - `follow_up_task`
  - `organization_member`
  - `review_decision`
- Leftover template code: `GreetingEndpoint` (a public, unauthenticated RPC), `greeting.spy.yaml`, `greetings_screen.dart`, and an empty `test/widget_test.dart`.

### Auth and Trust
- Expired sessions show "Check the local server connection" (`fieldnote_view_model.dart:286`).
- The profile is saved before consent, which takes two round trips (`onboarding_view.dart:302-339`). Combine them in one transaction.
- `acceptLegalConsent` overwrites the row, so consent history is lost (EP:107-118). Use an append-only table.
- The "Consent recorded" pill always shows (`trust_center_view.dart:200`). Activity entries show the time with no date (`:295`).
- The retention notice promises deletion that never happens (EP:153).
- No Terms or Privacy links on the signup screen.

### Platform
- The dev `publicHost` is a Cloudflare tunnel URL (`config/development.yaml:12`).
- DB passwords are committed in `docker-compose.yaml` and the CI workflow (dev/test values only).
- CI doesn't analyze, test or build the Flutter app.
- Branding is still the template: stock icons, "Fieldnotes Flutter", "A new Flutter project".
- No localization, no dark mode, and thin accessibility (18 semantics labels; the fixed 62px hero text may clip at large text sizes).
- Portrait is forced even on tablets and web, despite the wide layout.
- The READMEs are stubs, and `AGENTS.md` is out of date (seeding, `hackathon_ai_service.dart`).

---

## 5. Test coverage

- **Unit tests** (8 files): readiness policy, trust services, AI router, Gemini, Groq, Maps routes, summary, `observation_ai`.
- **Integration:** `test/integration/fieldnote_endpoint_test.dart`, about 22 tests.
- **Methods not tested:**
  - `verifyRazorpayPayment`
  - `createRazorpayOrder`
  - `requestAccountDeletion`
  - `completeParticipation`
  - `getEvidenceUploadDescription`
  - `postponeCampaign`
  - `watchCampaign`
- **Scenarios not tested:** concurrent payment verification, expiry refunds, the sweep future call, webhook and reconciliation, rate limits.
- **Flutter:** no widget or integration tests.

## 6. What already works

- Joining and the last-seat race: row lock plus a unique index.
- Crediting a payment is idempotent (`forUpdate` locks), and the Razorpay signature is compared in constant time.
- Role lock and consent-version checks are enforced on the server (EP:3055, EP:3277-3300).
- Publish requires a pin; the draft survives tab switches (`IndexedStack`); checkout double-taps are guarded.
- Secrets are read from `session.passwords`; the Maps key isn't load-bearing and falls back gracefully.
- Empty states exist for no matches, no map, no invites and no joined campaigns.

---

## 7. Suggested order

1. **Money:** P0-1, P0-2, P0-3, P0-4, A-4, S-1, S-2.
2. **Lifecycle:** P0-5, V-1, V-2, V-3, A-1, A-10, S-5.
3. **Compliance:** P0-6, P0-7, T-2, T-3, A-2.
4. **Volunteer UX:** P0-8, V-4 to V-10.
5. **Sponsor UX:** S-3, S-4, S-6 to S-10.
6. **Release:** P0-9, P0-10, P0-11, A-3, A-8, A-9, R-1 to R-7.
7. **P2 polish and tests** for each change above.
