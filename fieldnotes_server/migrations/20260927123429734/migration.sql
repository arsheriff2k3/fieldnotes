BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_test_payout" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "sponsorshipId" bigint NOT NULL,
    "creatorAuthUserId" uuid NOT NULL,
    "amount" double precision NOT NULL,
    "sourcePaymentId" text NOT NULL,
    "status" text NOT NULL DEFAULT 'simulated'::text,
    "simulatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_test_payout_campaign_idx" ON "fieldnote_test_payout" USING btree ("campaignId");
CREATE UNIQUE INDEX "fieldnote_test_payout_sponsorship_idx" ON "fieldnote_test_payout" USING btree ("sponsorshipId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_test_payout"
    ADD CONSTRAINT "fieldnote_test_payout_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "fieldnote_test_payout"
    ADD CONSTRAINT "fieldnote_test_payout_fk_1"
    FOREIGN KEY("sponsorshipId")
    REFERENCES "fieldnote_sponsorship"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20260927123429734', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260927123429734', "timestamp" = now();

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
