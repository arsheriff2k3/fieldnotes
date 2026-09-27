BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_campaign" ADD COLUMN "minimumVolunteers" bigint NOT NULL DEFAULT 1;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "readinessState" text NOT NULL DEFAULT 'open'::text;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "revision" bigint NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "readinessCheckedAt" timestamp without time zone;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "confirmedAt" timestamp without time zone;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "decisionDueAt" timestamp without time zone;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "postponedAt" timestamp without time zone;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "cancelledAt" timestamp without time zone;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_campaign_participation" ADD COLUMN "confirmedRevision" bigint NOT NULL DEFAULT 0;

--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20260927130713251', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260927130713251', "timestamp" = now();

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
