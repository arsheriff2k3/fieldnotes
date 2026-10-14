BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_campaign" ADD COLUMN "completedAt" timestamp without time zone;
CREATE INDEX "fieldnote_campaign_status_starts_idx" ON "fieldnote_campaign" USING btree ("status", "startsAt");
CREATE INDEX "fieldnote_campaign_created_by_idx" ON "fieldnote_campaign" USING btree ("createdBy");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_campaign_participation" ADD COLUMN "leftAt" timestamp without time zone;
ALTER TABLE "fieldnote_campaign_participation" ADD COLUMN "resolvedAt" timestamp without time zone;
ALTER TABLE "fieldnote_campaign_participation" ADD COLUMN "evidenceUploadPath" text;
ALTER TABLE "fieldnote_campaign_participation" ADD COLUMN "aiAnalyzedAt" timestamp without time zone;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_completion_evidence" ADD COLUMN "aiGenerated" boolean NOT NULL DEFAULT true;
ALTER TABLE "fieldnote_completion_evidence" ADD COLUMN "reviewState" text NOT NULL DEFAULT 'awaitingReview'::text;
ALTER TABLE "fieldnote_completion_evidence" ADD COLUMN "reviewNote" text;
ALTER TABLE "fieldnote_completion_evidence" ADD COLUMN "reviewedByAuthUserId" uuid;
ALTER TABLE "fieldnote_completion_evidence" ADD COLUMN "reviewedAt" timestamp without time zone;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_payment_webhook_event" (
    "id" bigserial PRIMARY KEY,
    "provider" text NOT NULL DEFAULT 'razorpay'::text,
    "eventId" text NOT NULL,
    "eventType" text NOT NULL,
    "payloadSha256" text NOT NULL,
    "status" text NOT NULL DEFAULT 'received'::text,
    "detail" text,
    "attempts" bigint NOT NULL DEFAULT 1,
    "receivedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_payment_webhook_event_id_idx" ON "fieldnote_payment_webhook_event" USING btree ("provider", "eventId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "failureReason" text;
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "reconcileAttempts" bigint NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "lastReconciledAt" timestamp without time zone;
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "updatedAt" timestamp without time zone;
CREATE INDEX "fieldnote_sponsorship_campaign_status_idx" ON "fieldnote_sponsorship" USING btree ("campaignId", "paymentStatus");
CREATE INDEX "fieldnote_sponsorship_status_idx" ON "fieldnote_sponsorship" USING btree ("paymentStatus", "createdAt");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "reason" text NOT NULL DEFAULT 'campaign_cancelled'::text;
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "testMode" boolean NOT NULL DEFAULT true;
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "attempts" bigint NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "providerRefundId" text;
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "lastError" text;
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "nextAttemptAt" timestamp without time zone;
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "processedAt" timestamp without time zone;
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "fieldnote_test_refund" ALTER COLUMN "status" SET DEFAULT 'pending'::text;
CREATE INDEX "fieldnote_test_refund_status_idx" ON "fieldnote_test_refund" USING btree ("status");

--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20261001084803764-money-lifecycle', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261001084803764-money-lifecycle', "timestamp" = now();

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
