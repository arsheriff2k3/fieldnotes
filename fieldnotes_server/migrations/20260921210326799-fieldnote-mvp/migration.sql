BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_asset" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "externalId" text NOT NULL,
    "species" text,
    "plantedAt" timestamp without time zone,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "notes" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_asset_campaign_external_idx" ON "fieldnote_asset" USING btree ("campaignId", "externalId");
CREATE INDEX "fieldnote_asset_campaign_idx" ON "fieldnote_asset" USING btree ("campaignId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_campaign" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "name" text NOT NULL,
    "description" text NOT NULL,
    "locationName" text NOT NULL,
    "startsAt" timestamp without time zone NOT NULL,
    "endsAt" timestamp without time zone,
    "status" text NOT NULL,
    "createdBy" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_campaign_organization_idx" ON "fieldnote_campaign" USING btree ("organizationId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_follow_up_task" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "observationId" bigint,
    "assetId" bigint,
    "title" text NOT NULL,
    "description" text NOT NULL,
    "assigneeAuthUserId" uuid,
    "dueAt" timestamp without time zone,
    "status" text NOT NULL,
    "createdBy" uuid NOT NULL,
    "completionNote" text,
    "completedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_task_campaign_status_idx" ON "fieldnote_follow_up_task" USING btree ("campaignId", "status");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_observation" (
    "id" bigserial PRIMARY KEY,
    "clientId" text NOT NULL,
    "campaignId" bigint NOT NULL,
    "assetId" bigint,
    "observerAuthUserId" uuid NOT NULL,
    "capturedAt" timestamp without time zone NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "accuracyMeters" double precision NOT NULL,
    "originalNote" text NOT NULL,
    "species" text,
    "condition" text NOT NULL,
    "issues" text NOT NULL,
    "recommendedFollowUp" text NOT NULL,
    "aiConfidence" text NOT NULL,
    "aiRationale" text NOT NULL,
    "reviewState" text NOT NULL,
    "possibleDuplicateAssetId" bigint,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_observation__clientId__unique_idx" ON "fieldnote_observation" USING btree ("clientId");
CREATE INDEX "fieldnote_observation_campaign_idx" ON "fieldnote_observation" USING btree ("campaignId");
CREATE INDEX "fieldnote_observation_review_idx" ON "fieldnote_observation" USING btree ("campaignId", "reviewState");
CREATE INDEX "fieldnote_observation_asset_idx" ON "fieldnote_observation" USING btree ("assetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_observation_media" (
    "id" bigserial PRIMARY KEY,
    "observationId" bigint NOT NULL,
    "storagePath" text NOT NULL,
    "mediaType" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_media_observation_idx" ON "fieldnote_observation_media" USING btree ("observationId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_organization" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "createdBy" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_organization_name_idx" ON "fieldnote_organization" USING btree ("name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_organization_member" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "authUserId" uuid NOT NULL,
    "displayName" text NOT NULL,
    "role" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_member_user_org_idx" ON "fieldnote_organization_member" USING btree ("organizationId", "authUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_review_decision" (
    "id" bigserial PRIMARY KEY,
    "observationId" bigint NOT NULL,
    "reviewerAuthUserId" uuid NOT NULL,
    "outcome" text NOT NULL,
    "previousCondition" text NOT NULL,
    "finalCondition" text NOT NULL,
    "notes" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_review_observation_idx" ON "fieldnote_review_decision" USING btree ("observationId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_asset"
    ADD CONSTRAINT "fieldnote_asset_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_campaign"
    ADD CONSTRAINT "fieldnote_campaign_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "fieldnote_organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_follow_up_task"
    ADD CONSTRAINT "fieldnote_follow_up_task_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "fieldnote_follow_up_task"
    ADD CONSTRAINT "fieldnote_follow_up_task_fk_1"
    FOREIGN KEY("observationId")
    REFERENCES "fieldnote_observation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "fieldnote_follow_up_task"
    ADD CONSTRAINT "fieldnote_follow_up_task_fk_2"
    FOREIGN KEY("assetId")
    REFERENCES "fieldnote_asset"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_observation"
    ADD CONSTRAINT "fieldnote_observation_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "fieldnote_observation"
    ADD CONSTRAINT "fieldnote_observation_fk_1"
    FOREIGN KEY("assetId")
    REFERENCES "fieldnote_asset"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "fieldnote_observation"
    ADD CONSTRAINT "fieldnote_observation_fk_2"
    FOREIGN KEY("possibleDuplicateAssetId")
    REFERENCES "fieldnote_asset"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_observation_media"
    ADD CONSTRAINT "fieldnote_observation_media_fk_0"
    FOREIGN KEY("observationId")
    REFERENCES "fieldnote_observation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_organization_member"
    ADD CONSTRAINT "fieldnote_organization_member_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "fieldnote_organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_review_decision"
    ADD CONSTRAINT "fieldnote_review_decision_fk_0"
    FOREIGN KEY("observationId")
    REFERENCES "fieldnote_observation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20260921210326799-fieldnote-mvp', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260921210326799-fieldnote-mvp', "timestamp" = now();

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
