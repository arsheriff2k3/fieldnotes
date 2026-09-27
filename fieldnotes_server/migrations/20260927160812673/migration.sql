BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_campaign_invitation" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "volunteerAuthUserId" uuid NOT NULL,
    "sponsorAuthUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_invitation_campaign_volunteer_idx" ON "fieldnote_campaign_invitation" USING btree ("campaignId", "volunteerAuthUserId");
CREATE INDEX "fieldnote_invitation_volunteer_idx" ON "fieldnote_campaign_invitation" USING btree ("volunteerAuthUserId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_campaign_invitation"
    ADD CONSTRAINT "fieldnote_campaign_invitation_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20260927160812673', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260927160812673', "timestamp" = now();

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
