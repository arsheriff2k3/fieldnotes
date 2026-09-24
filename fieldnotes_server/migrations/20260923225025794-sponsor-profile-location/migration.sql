BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_user_profile" ADD COLUMN "locationAddress" text;
ALTER TABLE "fieldnote_user_profile" ADD COLUMN "locationPlaceId" text;
ALTER TABLE "fieldnote_user_profile" ADD COLUMN "locationLatitude" double precision;
ALTER TABLE "fieldnote_user_profile" ADD COLUMN "locationLongitude" double precision;

--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20260923225025794-sponsor-profile-location', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260923225025794-sponsor-profile-location', "timestamp" = now();

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
