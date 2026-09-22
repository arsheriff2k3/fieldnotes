# FieldNote — Sponsor × Volunteer hackathon build

## Product outcome

FieldNote is now a focused two-role product. A **Sponsor** turns an idea into a funded campaign; a **Volunteer** publishes availability, receives explainable AI matches, performs the work, and returns GPS- and photo-backed evidence. There is no coordinator, reviewer, or separate campaign-creator account in the user experience. The sponsor is the campaign creator.

## The 3-minute judge story

1. Sign up as a Sponsor and describe a campaign in one sentence.
2. AI extracts a title, schedule, location, budget, volunteer capacity, work checklist, skills, and evidence requirement.
3. Publish at the device GPS location and complete Razorpay Test Mode checkout; Serverpod verifies the returned signature before updating funding.
4. On a second account/device, sign up as a Volunteer and mark availability, days, radius, interests, skills, and GPS area.
5. Open Matches. AI ranks campaigns and explains the score using availability, distance, interests, and capacity.
6. Join the campaign and perform a geofenced GPS check-in. When demonstrating away from the seed venue, use the explicitly labeled **Use demo GPS** option.
7. Take or select a photograph, dictate the field result, and let AI structure quantities/actions. The volunteer edits and confirms the summary.
8. Return to Sponsor Impact for the updated funding/evidence loop, then open Trust to show the payment, GPS, moderation, and consent audit trail.

## Implemented product surface

### Account and roles

- Role-first signup with **Create Sponsor Account** and **Create Volunteer Account**.
- Email authentication through Serverpod Auth.
- Role-specific onboarding and an immutable account role.
- Sponsor types: individual, company, foundation, or community group.
- Volunteer availability is a first-class record, not a profile footnote.

### Sponsor journey

- Discover and fund open campaigns through the real Razorpay Test Mode checkout (no real money moves).
- Create Razorpay orders on Serverpod and verify HMAC-SHA256 checkout signatures before funding totals change.
- Generate a structured campaign proposal from natural-language intent.
- Use live device GPS for a campaign pin, with a labeled local-demo fallback.
- Publish campaigns and monitor evidence-backed impact.
- Receive Serverpod stream updates for publish, sponsorship, join, check-in, and completion events.

### Volunteer journey

- Publish availability state, “available today,” regular days, time window, travel radius, GPS area, interests, and skills.
- Receive explainable matches scored from:
  - availability: 40 points;
  - travel distance: 30 points;
  - interest/tag overlap: 20 points;
  - open capacity: 10 points.
- Join a campaign and check in inside its 200-meter geofence.
- Use the visible Live Location Check panel to request Precise Location and demonstrate streaming coordinates, accuracy, sample age, device mock flag, and live distance to the geofence before check-in.
- Use an explicit demo-GPS simulation when a hackathon is not at the seeded Pune location.
- Reject stale, inaccurate, invalid, or device-reported mock live locations and check movement continuity between check-in and completion.
- Capture camera/gallery evidence, use real on-device speech recognition, review an AI-generated structured result, and submit private evidence.

### Backend and data

- Authenticated Serverpod endpoint with role guards and ownership checks.
- PostgreSQL tables for profiles, availability, sponsorships, participations, completion evidence, and campaign posts.
- Expanded campaign model for funding, coordinates, geofence, capacity, checklist, skills, tags, and AI provenance.
- Private Serverpod storage with upload verification and temporary download URLs.
- Gemini structured-output adapter for campaign generation and multimodal photo-plus-note evidence analysis, with a deterministic local fallback when no Gemini key is configured.
- Three idempotently seeded campaigns around the hackathon demo venue.
- Versioned privacy/AI/location/evidence consent, deterministic text moderation, structured audit events, user data export, and deletion-request recording.

## Local run

From the repository root:

```bash
cd fieldnotes
export SERVERPOD_PASSWORD_geminiApiKey='YOUR_GEMINI_KEY'
export SERVERPOD_PASSWORD_geminiModel='gemini-3.8-flash'
export SERVERPOD_PASSWORD_razorpayKeyId='rzp_test_...'
export SERVERPOD_PASSWORD_razorpayKeySecret='YOUR_TEST_SECRET'
serverpod start
```

The user runs `serverpod start`; automation must not start it. Development startup applies the pending migration and watches Serverpod/Flutter changes.

Register two different email accounts. Use one as Sponsor and one as Volunteer. Development email verification codes appear in the Serverpod log.

## Physical Android device

The phone and laptop must be on the same Wi-Fi network.

### Fastest USB demo (works with the included APK)

The generated debug APK uses the default `localhost:8080` server URL. Keep the Android device attached by USB and route its port to the laptop before opening the app:

```bash
adb reverse tcp:8080 tcp:8080
adb install -r fieldnotes_flutter/build/app/outputs/flutter-apk/app-debug.apk
```

This also keeps private photo upload/download URLs reachable without editing server configuration.

### Wi-Fi-only demo

1. Find the laptop LAN address on macOS:

   ```bash
   ipconfig getifaddr en0
   ```

2. In `fieldnotes_server/config/development.yaml`, set the API, Insights, and web `publicHost` values to that LAN IP before starting the stack. This is required because private upload descriptions must be reachable from the phone.
3. Run or build Flutter with the same address (keep the trailing slash):

   ```bash
   cd fieldnotes_flutter
   flutter run --dart-define=SERVER_URL=http://YOUR_LAN_IP:8080/
   ```

4. To install a reusable debug APK:

   ```bash
   flutter build apk --debug --dart-define=SERVER_URL=http://YOUR_LAN_IP:8080/
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   ```

Android includes camera, location, microphone, Internet, and local cleartext-network permissions for this LAN demo. iOS includes the corresponding usage descriptions.

## Manual acceptance checklist

### Sponsor account

- Role selection survives the transition into email signup.
- Sponsor profile opens the Sponsor workspace.
- AI rejects a very short campaign prompt and structures a detailed prompt.
- GPS selection shows whether the coordinate is live or the demo venue.
- Publishing creates the campaign and opens Impact.
- Razorpay Test Mode checkout opens and a successful test payment changes the campaign total only after server verification.
- Cancelling or failing Checkout leaves campaign funding unchanged.
- Impact shows joins/check-ins/completions after volunteer actions.

### Volunteer account

- Availability can be paused and restored.
- Day/radius/GPS changes alter match scores or ordering.
- Every match shows a score and human-readable reasons.
- Join is idempotent and moves the campaign to My Work.
- An outside-geofence live check-in is rejected.
- Enabling Live Location shows changing coordinates, accuracy, freshness, mock-location status, and inside/outside-geofence distance on the device.
- Explicit demo GPS succeeds for the local presentation.
- A live device mock-location flag is rejected; the explicit demo mode remains visibly labeled.
- Completion is blocked before check-in and without an uploaded photo.
- Microphone dictation populates the note; typed input remains available.
- The AI summary is editable and only submitted after volunteer confirmation.

### Cross-role/security

- Volunteers cannot generate/publish/fund campaigns.
- Sponsors cannot join or check in to campaigns.
- A volunteer cannot mutate another volunteer’s participation.
- Unauthenticated endpoint calls are rejected.
- Private evidence uses temporary access URLs rather than public object paths.
- Trust shows consent versions and auditable payment, location, moderation, export, and deletion-request activity.
- Data export returns the signed-in user's JSON summary; deletion request records an auditable local request.

## Scope boundary

This is a production-shaped local hackathon MVP, not a public payment or legal-compliance platform. Razorpay Test Mode, consent, first-pass moderation, audit history, privacy controls, and layered GPS integrity are implemented for the APK demo. A public launch still needs Razorpay live activation/webhooks/refunds, device attestation, a reviewed privacy policy and terms, automatic retention/deletion jobs, human appeals/moderation operations, external observability/alerts, rate limiting, incident response, and a full security/legal review. Production deployment/domain and Play Store/App Store signing remain intentionally out of scope.
