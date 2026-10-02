BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "fieldnote_review_decision" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "fieldnote_organization_member" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "fieldnote_observation_media" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "fieldnote_observation" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "fieldnote_follow_up_task" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "fieldnote_asset" CASCADE;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_campaign" ADD COLUMN "fundingGoalPaise" bigint NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "sponsoredAmountPaise" bigint NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "refundedAmountPaise" bigint NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_campaign" ADD COLUMN "clientRequestId" text;
CREATE UNIQUE INDEX "fieldnote_campaign_client_request_idx" ON "fieldnote_campaign" USING btree ("createdBy", "clientRequestId");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "amountPaise" bigint NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "clientRequestId" text;
CREATE UNIQUE INDEX "fieldnote_sponsorship_client_request_idx" ON "fieldnote_sponsorship" USING btree ("sponsorAuthUserId", "clientRequestId");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_test_payout" ADD COLUMN "amountPaise" bigint NOT NULL DEFAULT 0;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "amountPaise" bigint NOT NULL DEFAULT 0;
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "fundingReversedAt" timestamp without time zone;
ALTER TABLE "fieldnote_test_refund" ADD COLUMN "fundingReversedPaise" bigint NOT NULL DEFAULT 0;

--
-- HAND-WRITTEN DATA TRANSFORMATION (A-4, refund funding reversal)
-- Data only: the schema is unchanged and still equals definition.sql.
--
-- 1. Backfill integer paise from the legacy rupee doubles. numeric ROUND is
--    half away from zero, matching Money.toPaise in Dart.
UPDATE "fieldnote_campaign" SET
    "fundingGoalPaise" = ROUND("fundingGoal"::numeric * 100)::bigint,
    "sponsoredAmountPaise" = ROUND("sponsoredAmount"::numeric * 100)::bigint;
UPDATE "fieldnote_sponsorship" SET "amountPaise" = ROUND("amount"::numeric * 100)::bigint;
UPDATE "fieldnote_test_payout" SET "amountPaise" = ROUND("amount"::numeric * 100)::bigint;
UPDATE "fieldnote_test_refund" SET "amountPaise" = ROUND("amount"::numeric * 100)::bigint;

-- 2. Refunds processed before this release never reduced the campaign's
--    funded amount. Record each one as reversed exactly once (credited
--    payments only) and take the total off the campaign, never below zero.
UPDATE "fieldnote_test_refund" AS r SET
    "fundingReversedAt" = COALESCE(r."processedAt", now() AT TIME ZONE 'UTC'),
    "fundingReversedPaise" = CASE WHEN s."paymentStatus" = 'verified' THEN r."amountPaise" ELSE 0 END
FROM "fieldnote_sponsorship" AS s
WHERE s."id" = r."sponsorshipId" AND r."status" = 'processed';

UPDATE "fieldnote_campaign" AS c SET
    "refundedAmountPaise" = LEAST(t."total", c."sponsoredAmountPaise"),
    "sponsoredAmountPaise" = c."sponsoredAmountPaise" - LEAST(t."total", c."sponsoredAmountPaise")
FROM (
    SELECT "campaignId", SUM("fundingReversedPaise")::bigint AS "total"
    FROM "fieldnote_test_refund"
    WHERE "fundingReversedPaise" > 0
    GROUP BY "campaignId"
) AS t
WHERE t."campaignId" = c."id";

-- 3. Keep the legacy doubles equal to paise / 100 for older clients.
UPDATE "fieldnote_campaign" SET "sponsoredAmount" = "sponsoredAmountPaise" / 100.0
WHERE "refundedAmountPaise" > 0;

--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20261002062415263-money-paise-idempotency', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261002062415263-money-paise-idempotency', "timestamp" = now();

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
