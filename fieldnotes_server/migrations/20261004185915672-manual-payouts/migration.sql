BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_manual_payout_request" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "creatorAuthUserId" uuid NOT NULL,
    "clientRequestId" text NOT NULL,
    "sponsorshipIds" json NOT NULL,
    "grossAmountPaise" bigint NOT NULL,
    "deductionPaise" bigint NOT NULL DEFAULT 0,
    "amountPaise" bigint NOT NULL,
    "status" text NOT NULL DEFAULT 'requested'::text,
    "requestedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewedByAuthUserId" uuid,
    "reviewedAt" timestamp without time zone,
    "settlementReference" text,
    "payeeVerificationReference" text,
    "reviewNote" text,
    "bankTransferReference" text,
    "paidAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "fieldnote_manual_payout_campaign_idx" ON "fieldnote_manual_payout_request" USING btree ("campaignId");
CREATE INDEX "fieldnote_manual_payout_status_idx" ON "fieldnote_manual_payout_request" USING btree ("status", "requestedAt");
CREATE INDEX "fieldnote_manual_payout_creator_idx" ON "fieldnote_manual_payout_request" USING btree ("creatorAuthUserId");
CREATE UNIQUE INDEX "fieldnote_manual_payout_client_idx" ON "fieldnote_manual_payout_request" USING btree ("creatorAuthUserId", "clientRequestId");
CREATE UNIQUE INDEX "fieldnote_manual_payout_transfer_idx" ON "fieldnote_manual_payout_request" USING btree ("bankTransferReference");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "fieldnote_sponsorship" ADD COLUMN "paymentTestMode" boolean;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_manual_payout_request"
    ADD CONSTRAINT "fieldnote_manual_payout_request_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20261004185915672-manual-payouts', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261004185915672-manual-payouts', "timestamp" = now();

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
