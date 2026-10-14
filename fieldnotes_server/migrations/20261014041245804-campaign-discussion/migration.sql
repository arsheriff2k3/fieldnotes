BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fieldnote_campaign_chat_message" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "senderAuthUserId" uuid NOT NULL,
    "senderDisplayName" text NOT NULL,
    "senderIsCreator" boolean NOT NULL,
    "body" text NOT NULL,
    "clientRequestId" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_chat_campaign_id_idx" ON "fieldnote_campaign_chat_message" USING btree ("campaignId", "id");
CREATE UNIQUE INDEX "fieldnote_chat_request_idx" ON "fieldnote_campaign_chat_message" USING btree ("campaignId", "senderAuthUserId", "clientRequestId");
CREATE INDEX "fieldnote_chat_sender_idx" ON "fieldnote_campaign_chat_message" USING btree ("senderAuthUserId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fieldnote_campaign_chat_message"
    ADD CONSTRAINT "fieldnote_campaign_chat_message_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20261014041245804-campaign-discussion', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014041245804-campaign-discussion', "timestamp" = now();

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
