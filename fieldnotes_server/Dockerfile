# Build from the project root with:
# docker build -f fieldnotes_server/Dockerfile .
#
# Secrets are NOT baked into the image. The root .dockerignore excludes
# config/passwords.yaml and .env*, and the build stage deletes any copy that
# slips through. At runtime, provide every password as an environment
# variable named SERVERPOD_PASSWORD_<key>, where <key> is the exact
# (case-sensitive) passwords.yaml key, e.g. SERVERPOD_PASSWORD_razorpayKeySecret.
# The database, Redis and service secrets can alternatively use
# SERVERPOD_DATABASE_PASSWORD, SERVERPOD_REDIS_PASSWORD and
# SERVERPOD_SERVICE_SECRET. See docs/DEPLOYMENT.md for the full list.

# Build stage
FROM dart:3.12.2 AS build

# Create a minimal workspace that preserves locked server dependency versions.
WORKDIR /app
COPY pubspec.lock .
COPY fieldnotes_server fieldnotes_server
# Defence in depth: never let local secrets reach the final image even if the
# build is run with a context that bypasses .dockerignore.
RUN rm -f fieldnotes_server/config/passwords.yaml \
  fieldnotes_server/config/firebase_service_account_key.json \
  && find fieldnotes_server -name '.env*' -type f -delete
RUN printf '%s\n' \
  'name: _' \
  'environment:' \
  '  sdk: ^3.12.2' \
  'workspace:' \
  '  - fieldnotes_server' \
  > pubspec.yaml
RUN dart pub get

# Compile the server executable.
WORKDIR /app/fieldnotes_server
RUN dart build cli --target bin/main.dart --output build
RUN mv build/bundle/bin/main build/bundle/bin/server

# Add a fallback for the copy of possibly missing directories.
RUN mkdir -p config web migrations

# Final stage
FROM alpine:latest
WORKDIR /app

# Environment variables
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

# Copy runtime dependencies
COPY --from=build /runtime/ /

# Copy compiled server executable and native libraries
COPY --from=build /app/fieldnotes_server/build/bundle/ ./

# Copy configuration files and resources
COPY --from=build /app/fieldnotes_server/config/ config/
COPY --from=build /app/fieldnotes_server/web/ web/
COPY --from=build /app/fieldnotes_server/migrations/ migrations/

# This file is required to enable the endpoint log filter in Insights.
COPY --from=build /app/fieldnotes_server/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

# Expose ports
EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

# Define the entrypoint command
ENTRYPOINT ./bin/server --mode=$runmode --server-id=$serverid --logging=$logging --role=$role
