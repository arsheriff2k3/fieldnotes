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
```

Do not replace the existing database, email pepper, JWT, refresh-token, or service-secret entries.

If you prefer shell environment variables instead of editing YAML, Serverpod maps custom passwords using this exact prefix:

```bash
export SERVERPOD_PASSWORD_geminiApiKey='...'
export SERVERPOD_PASSWORD_geminiModel='gemini-3.8-flash'
export SERVERPOD_PASSWORD_geminiTranscriptionModel='gemini-3.5-transcribe'
export SERVERPOD_PASSWORD_razorpayKeyId='rzp_test_...'
export SERVERPOD_PASSWORD_razorpayKeySecret='...'
```

Set these in the same terminal that runs `serverpod start`. Do not add them to a committed shell script.

### Local `.env` option

Serverpod reads the variables above but does not automatically load a `.env` file. The repository includes a safe template and loader script:

```bash
cd /Users/ryan/Desktop/Project/serverpod/fieldnotes
cp .env.example .env
```

Edit `.env`, replace the three secret placeholders, and start locally with:

```bash
./start-local.sh
```

The real `.env` is ignored by Git. Keep the `SERVERPOD_PASSWORD_` prefixes unchanged; Serverpod strips that prefix when exposing the values through its password API.

### Gemini

Required:

- A Google AI Studio or Gemini API project.
- A Gemini API key with Generative Language API access and available quota.
- Default model: `gemini-3.8-flash`, a stable multimodal model with Structured Outputs.

The key remains on the Serverpod server. The intended integration uses:

- `POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`
- structured JSON schemas for campaign proposals and evidence extraction;
- the volunteer evidence photograph plus the original note for multimodal extraction;
- deterministic fallback only when the key is absent in local development.

Restrict the key to the Generative Language API and the server's IP/application restrictions when available. Configure quota and billing alerts before public testing.

### Razorpay

Required for manual testing:

- Razorpay account with **Test Mode** enabled.
- Test Key ID beginning with `rzp_test_`.
- Matching Test Key Secret.
- No webhook is required for the local APK demo. A public deployment should add a webhook secret and handle `payment.captured`, `payment.failed`, `order.paid`, and refund events.

The server must create the Razorpay Order. Flutter receives only the Key ID and Order ID, opens checkout, and returns payment ID/order ID/signature to Serverpod. Serverpod verifies the HMAC-SHA256 signature before recording sponsorship. Never put `razorpayKeySecret` in Flutter.

For local USB testing, Razorpay Checkout returns directly to the app and Serverpod verifies the signature. Webhook testing is intentionally deferred with public deployment because it requires a public HTTPS endpoint.

## No key required

These features already use device/platform functionality and require no external API account:

- GPS location and geofence: `geolocator`
- camera/gallery evidence: `image_picker`
- speech recognition: `speech_to_text`
- local Serverpod PostgreSQL
- local Serverpod private object storage
- development email verification codes, which appear in the Serverpod log

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
