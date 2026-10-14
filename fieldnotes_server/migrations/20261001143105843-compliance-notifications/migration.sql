BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_account_deletion_request" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "lastError" text,
    "attempts" bigint NOT NULL DEFAULT 0,
    "nextAttemptAt" timestamp without time zone,
    "requestedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" timestamp without time zone,
    "completedAt" timestamp without time zone,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_account_deletion_user_idx" ON "fieldnote_account_deletion_request" USING btree ("authUserId");
CREATE INDEX "fieldnote_account_deletion_status_idx" ON "fieldnote_account_deletion_request" USING btree ("status");

--
-- ACTION ALTER TABLE
--
CREATE INDEX "fieldnote_audit_actor_time_idx" ON "fieldnote_audit_event" USING btree ("actorAuthUserId", "occurredAt");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_campaign" ADD COLUMN "shareSlug" text;
-- Hand-added data step (allowed by AGENTS.md): give every existing campaign
-- an unguessable share slug before the unique index is built. 32 hex chars
-- from md5 of random input plus the row id, so values are unique per row.
-- The schema is unchanged and still matches definition.sql (nullable text).
UPDATE "fieldnote_campaign"
    SET "shareSlug" = md5(random()::text || clock_timestamp()::text || "id"::text)
    WHERE "shareSlug" IS NULL;
CREATE UNIQUE INDEX "fieldnote_campaign_share_slug_idx" ON "fieldnote_campaign" USING btree ("shareSlug");
--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_legal_consent_history" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "action" text NOT NULL,
    "privacyPolicyVersion" text NOT NULL,
    "termsVersion" text NOT NULL,
    "locationConsent" boolean NOT NULL,
    "aiProcessingConsent" boolean NOT NULL,
    "evidenceSharingConsent" boolean NOT NULL,
    "recordedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_consent_history_user_idx" ON "fieldnote_legal_consent_history" USING btree ("authUserId", "recordedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_notification_outbox" (
    "id" bigserial PRIMARY KEY,
    "recipientAuthUserId" uuid NOT NULL,
    "kind" text NOT NULL,
    "dedupeKey" text NOT NULL,
    "subject" text NOT NULL,
    "bodyText" text NOT NULL,
    "bodyHtml" text NOT NULL,
    "toEmail" text,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "attempts" bigint NOT NULL DEFAULT 0,
    "lastError" text,
    "nextAttemptAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_notification_dedupe_idx" ON "fieldnote_notification_outbox" USING btree ("recipientAuthUserId", "dedupeKey");
CREATE INDEX "fieldnote_notification_status_idx" ON "fieldnote_notification_outbox" USING btree ("status", "nextAttemptAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_rate_limit_bucket" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "action" text NOT NULL,
    "windowStart" timestamp without time zone NOT NULL,
    "hits" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_rate_limit_bucket_key_idx" ON "fieldnote_rate_limit_bucket" USING btree ("authUserId", "action", "windowStart");
CREATE INDEX "fieldnote_rate_limit_bucket_window_idx" ON "fieldnote_rate_limit_bucket" USING btree ("windowStart");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_user_profile" ADD COLUMN "emailNotifications" boolean NOT NULL DEFAULT true;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_volunteer_availability" ADD COLUMN "timezone" text;
ALTER TABLE "fieldnote_volunteer_availability" ADD COLUMN "utcOffsetMinutes" bigint;
ALTER TABLE "fieldnote_volunteer_availability" ADD COLUMN "availableTodayDate" text;

--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20261001143105843-compliance-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261001143105843-compliance-notifications', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();


COMMIT;
