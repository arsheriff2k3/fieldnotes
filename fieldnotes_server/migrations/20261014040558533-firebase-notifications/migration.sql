BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_in_app_notification" (
    "id" bigserial PRIMARY KEY,
    "recipientAuthUserId" uuid NOT NULL,
    "kind" text NOT NULL,
    "dedupeKey" text NOT NULL,
    "title" text NOT NULL,
    "body" text NOT NULL,
    "campaignId" bigint,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "readAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_inbox_dedupe_idx" ON "fieldnote_in_app_notification" USING btree ("recipientAuthUserId", "dedupeKey");
CREATE INDEX "fieldnote_inbox_page_idx" ON "fieldnote_in_app_notification" USING btree ("recipientAuthUserId", "id");
CREATE INDEX "fieldnote_inbox_unread_idx" ON "fieldnote_in_app_notification" USING btree ("recipientAuthUserId", "readAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_push_delivery" (
    "id" bigserial PRIMARY KEY,
    "notificationId" bigint NOT NULL,
    "deviceId" bigint NOT NULL,
    "recipientAuthUserId" uuid NOT NULL,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "attempts" bigint NOT NULL DEFAULT 0,
    "nextAttemptAt" timestamp without time zone,
    "lastError" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_push_delivery_dedupe_idx" ON "fieldnote_push_delivery" USING btree ("notificationId", "deviceId");
CREATE INDEX "fieldnote_push_delivery_due_idx" ON "fieldnote_push_delivery" USING btree ("status", "nextAttemptAt");
CREATE INDEX "fieldnote_push_delivery_user_idx" ON "fieldnote_push_delivery" USING btree ("recipientAuthUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_push_device" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "token" text NOT NULL,
    "tokenHash" text NOT NULL,
    "platform" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_push_token_idx" ON "fieldnote_push_device" USING btree ("tokenHash");
CREATE INDEX "fieldnote_push_user_idx" ON "fieldnote_push_device" USING btree ("authUserId");


--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20261014040558533-firebase-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014040558533-firebase-notifications', "timestamp" = now();

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
