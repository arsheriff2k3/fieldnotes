# FieldNote

FieldNote turns sponsor intent into nearby, evidence-backed volunteer action.
It has exactly two account roles:

- **Sponsors** describe a campaign in plain language. AI drafts it, the sponsor
  pins it on a map, publishes it and funds it through Razorpay checkout. Payments
  are verified on the server. The sponsor then follows joins, check-ins and evidence live.
- **Volunteers** publish their availability, travel radius, interests, skills
  and GPS area. They get ranked matches with reasons (availability 40, distance 30,
  interests 20, remaining capacity 10), join, check in inside a 200 m geofence,
  and submit a photo and a typed or dictated note that AI turns into an impact summary.

A Trust area shows versioned consent, an audit trail of payment, location and
moderation events, a data export and a deletion request.

Sponsors can open **Campaign impact report** from a campaign in Impact and
save or share a PDF. Reports separate submitted, sponsor-approved, pending,
changes-requested and rejected evidence, show net funding and processed refunds,
and identify Test Mode payments and demo GPS. Only approved summaries are
exported; private photos, original notes and exact coordinates are omitted.
PDF labels are English. Refresh or export retrieves the latest review state.

The current state of production readiness is tracked in
[`docs/PRODUCTION_GAPS.md`](docs/PRODUCTION_GAPS.md).

Both roles have a private notification inbox and unread bell. Android device
alerts use Firebase Cloud Messaging, triggered by Serverpod through its outbox
worker. The app registers tokens and fetches notification details through
Serverpod; email preferences remain independent. See
[`docs/NOTIFICATIONS.md`](docs/NOTIFICATIONS.md)
for Android configuration, event coverage and expected timing.

## Architecture

```
fieldnotes_flutter/   Flutter app (Android, iOS, web; desktop scaffolds)
fieldnotes_client/    Generated Serverpod client (never edit by hand)
fieldnotes_server/    Serverpod 4 backend (Dart), PostgreSQL, optional Redis
docs/                 Setup, notifications, release limitations and deployment
```

- **Backend:** Serverpod with its built-in email authentication (JWT tokens).
  Hand-written code lives in `fieldnotes_server/lib/src/fieldnotes/`:
  `.spy.yaml` data models in `models/`, the RPC boundary in `fieldnote_endpoint.dart`,
  and integrations in `services/`:
  - Gemini and Groq AI, behind `ai_provider_router.dart`
  - Razorpay payments and creator manual payout requests
  - Google Maps Places, Geocoding and Routes
  - location integrity checks
  - content moderation

  A future call sweeps campaign readiness every 5 minutes. The web server
  (`lib/server.dart`) serves the built Flutter web app, `/c/<id>` campaign share
  pages and static files under `/web/`.
- **App:** a small MVVM/repository layout. `lib/data/repositories/` is the only layer
  that calls the generated client. Views and view models live in `lib/ui/features/`,
  and the design system in `lib/ui/core/`.
- **Maps** are additive. Without a client key every map shows a coordinate
  fallback, and geofencing uses the server's own maths.
- **Secrets** stay server-side in Serverpod passwords and never reach the app.
  See [`docs/SECRETS_AND_EXTERNAL_SERVICES.md`](docs/SECRETS_AND_EXTERNAL_SERVICES.md).

## Local development

Prerequisites: Flutter (the CI uses 3.44.4), the Serverpod CLI 4.0.0
(`dart install serverpod_cli 4.0.0`), and Docker if you want the compose
Postgres/Redis.

```sh
flutter pub get                       # resolves the whole pub workspace

# Server secrets for local runs (both files are git-ignored):
cp .env.example .env                  # SERVERPOD_PASSWORD_* values for dev
#   and/or fieldnotes_server/config/passwords.yaml

# Client Maps key file (git-ignored; leave keys empty for coordinate fallback):
cp fieldnotes_flutter/.env.maps.example fieldnotes_flutter/.env.maps

./start-local.sh                      # loads .env, then runs `serverpod start`
```

`start-local.sh` exports `.env` and runs `serverpod start`. That command applies
pending migrations, starts the server (API on 8080, Insights on 8081, web on
8082), launches the Flutter app, and watches for changes, regenerating code and
hot-reloading both sides. If you keep your secrets in `config/passwords.yaml`
instead, you can run `serverpod start` directly from the repository.

After changing `.spy.yaml` models, create a migration (`serverpod create-migration`,
or the Serverpod MCP `create_migration` tool). `serverpod start` applies it.
Never edit `lib/src/generated/` or `fieldnotes_client/`.

### Physical Android device

With the server running and the phone connected by USB:

```sh
adb reverse tcp:8080 tcp:8080
adb reverse tcp:8082 tcp:8082
cd fieldnotes_flutter
flutter run -d <device-id>
```

Forward both ports: 8080 serves the API and private evidence; 8082 serves legal
and campaign share pages. Repeat the forwards after reconnecting USB. For
multiple devices, pass `adb -s <device-id>` for each forward.

For Wi-Fi, put the phone and laptop on the same network. Override the server
public hosts using
`SERVERPOD_API_SERVER_PUBLIC_HOST`, `SERVERPOD_INSIGHTS_SERVER_PUBLIC_HOST`
and `SERVERPOD_WEB_SERVER_PUBLIC_HOST` with the laptop's LAN IP, and run with
`--dart-define=SERVER_URL=http://<LAN-IP>:8080/`. Debug and profile builds allow
cleartext HTTP; release builds require HTTPS.

### Demo flow

Use two email accounts with accessible inboxes: one Sponsor and one Volunteer.
Configure SMTP for signup codes, an AI provider for drafting, and Razorpay
**Test Mode** keys for checkout. The sponsor drafts, publishes and funds a
campaign. The volunteer sets availability, joins, checks in, and submits photo
and note evidence. The sponsor reviews the evidence and exports an impact PDF.
Use the explicitly labeled demo GPS option when presenting away from the
campaign location.

## Testing

```sh
# Server: unit and integration tests. No Docker needed; config/test.yaml
# makes Serverpod start an embedded PostgreSQL.
cd fieldnotes_server
dart analyze --fatal-infos
dart format --output=none --set-exit-if-changed .
dart test

# App
cd ../fieldnotes_flutter
flutter analyze
flutter test
```

Use the Dart SDK bundled with the required Flutter version for these commands.

CI (`.github/workflows/`) runs server analyze, format and tests, plus Flutter
analyze and tests (`flutter.yml`).

## Configuration

| What | Where |
|---|---|
| Server run modes | `fieldnotes_server/config/{development,staging,production,test}.yaml`; any value can be overridden with `SERVERPOD_*` env vars |
| Server secrets | `SERVERPOD_PASSWORD_<key>` env vars (case-sensitive key) or the git-ignored `config/passwords.yaml` |
| App server URL | `--dart-define=SERVER_URL=https://…/`, otherwise `assets/config.json`, otherwise `http://localhost:8080/` |
| Shared link base | `--dart-define=CAMPAIGN_SHARE_BASE_URL=https://<link-host>`; without it links use `fieldnote://campaign/<id>` |
| Client Maps keys | `fieldnotes_flutter/.env.maps` (git-ignored; see the `.example`) |
| Android app ID, signing, link host | `fieldnotes_flutter/android/key.properties` (git-ignored; see `key.properties.example`) |
| iOS bundle ID, link host, team | `fieldnotes_flutter/ios/Flutter/AppIdentity.local.xcconfig` (git-ignored; see the `.example`) |

Release builds refuse placeholder app IDs, missing signing and a missing link
host. For production setup (secrets list, domains, signing, App Links and
Universal Links files, Razorpay webhook, Redis, SMTP, backups, store
requirements) follow [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).
