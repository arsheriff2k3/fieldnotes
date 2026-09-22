BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_audit_event" (
    "id" bigserial PRIMARY KEY,
    "actorAuthUserId" uuid NOT NULL,
    "event" text NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text,
    "outcome" text NOT NULL,
    "riskLevel" text NOT NULL,
    "detail" text NOT NULL,
    "occurredAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_audit_actor_idx" ON "fieldnote_audit_event" USING btree ("actorAuthUserId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_campaign_participation" ADD COLUMN "locationIntegrityStatus" text;
ALTER TABLE "fieldnote_campaign_participation" ADD COLUMN "locationIntegrityReasons" text;
ALTER TABLE "fieldnote_campaign_participation" ADD COLUMN "locationIsDemo" boolean NOT NULL DEFAULT false;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_completion_evidence" ADD COLUMN "locationIntegrityStatus" text NOT NULL DEFAULT 'verified'::text;
ALTER TABLE "fieldnote_completion_evidence" ADD COLUMN "locationIntegrityReasons" text NOT NULL DEFAULT 'Location checks passed'::text;
ALTER TABLE "fieldnote_completion_evidence" ADD COLUMN "locationIsDemo" boolean NOT NULL DEFAULT false;
ALTER TABLE "fieldnote_completion_evidence" ADD COLUMN "moderationStatus" text NOT NULL DEFAULT 'passed'::text;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_legal_consent" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "privacyPolicyVersion" text NOT NULL,
    "termsVersion" text NOT NULL,
    "locationConsent" boolean NOT NULL,
    "aiProcessingConsent" boolean NOT NULL,
    "evidenceSharingConsent" boolean NOT NULL,
    "acceptedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_legal_consent__authUserId__unique_idx" ON "fieldnote_legal_consent" USING btree ("authUserId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "paymentProvider" text NOT NULL DEFAULT 'razorpay'::text;
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "paymentStatus" text NOT NULL DEFAULT 'created'::text;
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "providerOrderId" text;
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "providerPaymentId" text;
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "verifiedAt" timestamp without time zone;
-- Rows created before this migration were explicitly simulated sponsorships.
-- Preserve that history without presenting them as unverified Razorpay orders.
UPDATE "fieldnote_sponsorship"
SET "paymentProvider" = 'simulated',
    "paymentStatus" = 'verified',
    "verifiedAt" = "createdAt"
WHERE "providerOrderId" IS NULL;
CREATE UNIQUE INDEX "fieldnote_sponsorship_provider_order_idx" ON "fieldnote_sponsorship" USING btree ("providerOrderId");

--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20260922104451396', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260922104451396', "timestamp" = now();

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
