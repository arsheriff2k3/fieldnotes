BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_in_app_notification" ADD COLUMN "unreadCount" bigint NOT NULL DEFAULT 1;
ALTER TABLE "fieldnote_in_app_notification" ADD COLUMN "chatMessageId" bigint;
--
-- ACTION ALTER TABLE
--
DROP INDEX "fieldnote_push_delivery_dedupe_idx";
ALTER TABLE "fieldnote_push_delivery" ADD COLUMN "notificationVersion" bigint NOT NULL DEFAULT 0;
CREATE UNIQUE INDEX "fieldnote_push_delivery_dedupe_idx" ON "fieldnote_push_delivery" USING btree ("notificationId", "deviceId", "notificationVersion");

--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20261014063030151-grouped-chat-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014063030151-grouped-chat-notifications', "timestamp" = now();

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
