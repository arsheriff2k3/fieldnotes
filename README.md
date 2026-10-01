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

The current state of production readiness is tracked in
[`docs/PRODUCTION_GAPS.md`](docs/PRODUCTION_GAPS.md).

## Architecture

```
fieldnotes_flutter/   Flutter app (Android, iOS, web; desktop scaffolds)
fieldnotes_client/    Generated Serverpod client (never edit by hand)
fieldnotes_server/    Serverpod 4 backend (Dart), PostgreSQL, optional Redis
docs/                 Plans, gap audit, secrets guide, deployment guide
```

- **Backend:** Serverpod with its built-in email authentication (JWT tokens).
  Hand-written code lives in `fieldnotes_server/lib/src/fieldnotes/`:
  `.spy.yaml` data models in `models/`, the RPC boundary in `fieldnote_endpoint.dart`,
  and integrations in `services/`:
  - Gemini and Groq AI, behind `ai_provider_router.dart`
  - Razorpay payments
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

# Optional client Maps keys (git-ignored):
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

To run on a physical Android device against your machine, see
[`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md). Debug and profile
builds allow cleartext HTTP; release builds do not.

## Testing

```sh
# Server: unit and integration tests. No Docker needed; config/test.yaml
# makes Serverpod start an embedded PostgreSQL.
cd fieldnotes_server && dart analyze && dart format . && dart test

# App
cd fieldnotes_flutter && flutter analyze && flutter test
```

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
