BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_campaign" ADD COLUMN "fundingGoal" double precision NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "sponsoredAmount" double precision NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "latitude" double precision NOT NULL DEFAULT 18.5204;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "longitude" double precision NOT NULL DEFAULT 73.8567;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "geofenceMeters" double precision NOT NULL DEFAULT 200;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "volunteerCapacity" bigint NOT NULL DEFAULT 10;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "requiredSkills" text NOT NULL DEFAULT ''::text;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "checklist" text NOT NULL DEFAULT ''::text;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "evidenceInstructions" text NOT NULL DEFAULT ''::text;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "tags" text NOT NULL DEFAULT ''::text;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "aiGenerated" boolean NOT NULL DEFAULT false;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "coverImagePath" text;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "publishedAt" timestamp without time zone;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_campaign_participation" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "volunteerAuthUserId" uuid NOT NULL,
    "status" text NOT NULL,
    "joinedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "checkedInAt" timestamp without time zone,
    "completedAt" timestamp without time zone,
    "checkInLatitude" double precision,
    "checkInLongitude" double precision,
    "checkInAccuracyMeters" double precision
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_participation_campaign_volunteer_idx" ON "fieldnote_campaign_participation" USING btree ("campaignId", "volunteerAuthUserId");
CREATE INDEX "fieldnote_participation_volunteer_idx" ON "fieldnote_campaign_participation" USING btree ("volunteerAuthUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_campaign_post" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "authorSponsorAuthUserId" uuid NOT NULL,
    "title" text NOT NULL,
    "body" text NOT NULL,
    "photographPath" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_post_campaign_idx" ON "fieldnote_campaign_post" USING btree ("campaignId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_completion_evidence" (
    "id" bigserial PRIMARY KEY,
    "participationId" bigint NOT NULL,
    "photographPath" text,
    "originalNote" text NOT NULL,
    "confirmedSummary" text NOT NULL,
    "structuredResults" text NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "locationAccuracyMeters" double precision NOT NULL,
    "submittedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_evidence_participation_idx" ON "fieldnote_completion_evidence" USING btree ("participationId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_sponsorship" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "sponsorAuthUserId" uuid NOT NULL,
    "amount" double precision NOT NULL,
    "message" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_sponsorship_campaign_idx" ON "fieldnote_sponsorship" USING btree ("campaignId");
CREATE INDEX "fieldnote_sponsorship_sponsor_idx" ON "fieldnote_sponsorship" USING btree ("sponsorAuthUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_user_profile" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "role" text NOT NULL,
    "displayName" text NOT NULL,
    "sponsorType" text,
    "organizationName" text,
    "city" text NOT NULL,
    "interests" text NOT NULL,
    "skills" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_user_profile__authUserId__unique_idx" ON "fieldnote_user_profile" USING btree ("authUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_volunteer_availability" (
    "id" bigserial PRIMARY KEY,
    "volunteerAuthUserId" uuid NOT NULL,
    "isAvailable" boolean NOT NULL DEFAULT true,
    "availableToday" boolean NOT NULL DEFAULT false,
    "weekdays" text NOT NULL,
    "startMinutes" bigint NOT NULL,
    "endMinutes" bigint NOT NULL,
    "maximumTravelKm" double precision NOT NULL,
    "latitude" double precision,
    "longitude" double precision,
    "locationLabel" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_volunteer_availability__volunte5714f5759f__unique_idx" ON "fieldnote_volunteer_availability" USING btree ("volunteerAuthUserId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_campaign_participation"
    ADD CONSTRAINT "fieldnote_campaign_participation_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_campaign_post"
    ADD CONSTRAINT "fieldnote_campaign_post_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_completion_evidence"
    ADD CONSTRAINT "fieldnote_completion_evidence_fk_0"
    FOREIGN KEY("participationId")
    REFERENCES "fieldnote_campaign_participation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_sponsorship"
    ADD CONSTRAINT "fieldnote_sponsorship_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20260922091415725-sponsor-volunteer-hackathon', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260922091415725-sponsor-volunteer-hackathon', "timestamp" = now();

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
