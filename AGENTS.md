# Flutter & Serverpod project

This project is a Flutter app (frontend) backed by a Serverpod server (backend). Always build the app's backend with Serverpod.
Build for multiple users, use Serverpod's built-in authentication, which is already set up in `lib/server.dart`.

## FieldNote Teams AI

FieldNote is a two-sided hackathon product that turns sponsor intent into nearby, evidence-backed volunteer action. It deliberately has only two account roles: **Sponsor** and **Volunteer**. There is no coordinator role in the demo product.

Core workflow:

- Signup begins by choosing Sponsor or Volunteer; the selected role is locked after onboarding.
- Sponsors create campaigns from natural-language intent, publish them at a GPS location, complete Razorpay Test Mode checkout, and monitor live impact after server-side signature verification.
- Volunteers explicitly publish availability, available days, travel radius, interests, skills, and a GPS area.
- AI matching scores campaigns using availability (40), distance (30), interests (20), and remaining capacity (10), with visible reasons.
- Volunteers join, check in inside a 200-meter geofence, capture a photograph, dictate or type a note, and confirm an AI-structured impact summary.
- Sponsors see funding, joins, completions, private evidence summaries, and streamed campaign events.
- Razorpay Test Mode uses the real provider checkout but moves no real money. The secret remains server-side and funding changes only after HMAC signature verification.
- The Trust area shows versioned consent, payment/location/moderation audit events, JSON data export, and a locally queued deletion request.
- Live GPS checks freshness, accuracy, valid bounds, device mock flags, geofence, and movement continuity. Explicit hackathon GPS remains labeled as demo data.

Hand-written backend code lives under `fieldnotes_server/lib/src/fieldnotes/`. Data contracts are `.spy.yaml` files under `models/`; `fieldnote_endpoint.dart` is the RPC boundary; `services/gemini_ai_service.dart` is the hosted structured/multimodal AI provider and `services/hackathon_ai_service.dart` is its credential-free development fallback. `services/google_maps_service.dart` holds the billed Google Maps web-service calls (Places, Geocoding, Routes) behind the `googleMapsApiKey` password. Never put business logic in generated files.

Google Maps is additive and never load-bearing. Map tiles use platform-restricted client keys from `fieldnotes_flutter/.env.maps`; when the current platform's key is absent every map renders a coordinate fallback panel and the app behaves exactly as it did before Maps. Geofence admission in `checkIn` uses the server's own haversine maths and must never depend on a Google call. Routes travel time refines match *ranking* only. Sponsor reach previews return k-anonymised buckets, never individual volunteer coordinates. See `docs/SECRETS_AND_EXTERNAL_SERVICES.md`.

The Flutter app uses a small MVVM/repository layout:

- `lib/data/services/` contains device services for pending role selection and location.
- `lib/data/repositories/` is the only layer that calls generated Serverpod endpoints.
- `lib/ui/features/` contains views and view models.
- `lib/ui/core/` contains the FieldNote design system.

`getMyProfile` ensures three public demo campaigns exist. Seeding is safe to call repeatedly. Real GPS is requested first; the clearly labeled hackathon demo venue is only a fallback or explicit simulation. Photo uploads use Serverpod private storage and must be verified before completion.

The user starts the server and Flutter app with `serverpod start`. There is no need to check if the server is running: make the changes and call the `serverpod` MCP tools as needed. If the server is not running, an informative error message will be received from the MCP server. Then STOP and ask the user to start it. NEVER start the server yourself. The Flutter app is started along with it, or can be launched from the MCP tool `spawn_flutter_app`.

While running, `serverpod start` watches for file changes to run incremental code generation and hot reload both the server and the Flutter app.

Calling `serverpod generate` directly is not needed, but might be useful to troubleshoot when an incremental generation fails.

ALWAYS use the MCP server instead of the command line. Use the MCP server to:

- `create_migration` and `apply_migrations` for database (after you change data models).
- `create_repair_migration` if the database has drifted out of sync with the migrations.
- `tail_server_logs` to read logs from the server.
- `tail_flutter_logs` to read the raw stdout/stderr of the Flutter app.
- `hot_reload` / `hot_restart` to reload or restart the server and the Flutter app. ALWAYS call `hot_restart` after doing changes in the Flutter app that may not work with normal hot reload (which is automatically applied).
- `spawn_flutter_app` to start a Flutter app declared under `serverpod: flutter_apps:` in the server `pubspec.yaml`.
- `get_flutter_app_dtd` (Dart tooling daemon) for connecting to the app through the `dart` MCP.

NEVER edit generated code. The server's `lib/src/generated/` directory and the whole `fieldnotes_client` package are rewritten by the code generator. Change the `.spy.yaml` models, the endpoints, or `lib/server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Only when the server cannot be started at all, fall back to the CLI in the server package:

- `serverpod generate` to regenerate the client and the generated server code.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). It only writes the migration; `serverpod start` applies pending migrations when it boots the server.

Tests need no Docker. `config/test.yaml` sets `database.dataPath`, so Serverpod starts and manages the test database (an embedded PostgreSQL) itself, and the project's `docker-compose.yaml` is not used for it. Just run `dart test` in the server package.

Checklist after doing changes, in this order:

- `dart analyze` (CLI)
- `dart format` (CLI)
- `create_migration` and `apply_migrations` (MCP - only if necessary)
- Do `serverpod` MCP `hot_restart` if required (hot reload is done automatically). Will also hot restart Flutter app
- Run tests, if applicable (`dart test` in the server package)
- Check `serverpod` MCP `tail_server_logs` and `tail_flutter_logs` for any issues.

If the user asks you to test the app:

1. Use `get_flutter_app_dtd` (`serverpod` MCP) to get the Flutter app's DTD
2. Pass the DTD to `connect_dart_tooling_daemon` (`dart` MCP) to connect to the app
3. Use `flutter_driver` (`dart` MCP) to navigate through the app

The app is launched from `fieldnotes_flutter/lib/driver.dart`, which starts the Flutter driver extension with text entry emulation turned off so the app stays usable by hand. To let the driver type, set `enableTextEntryEmulation: true` there and `hot_restart` the app.
