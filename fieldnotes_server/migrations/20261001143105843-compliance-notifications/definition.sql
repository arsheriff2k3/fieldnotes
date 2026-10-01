BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- Class AccountDeletionRequest as table fieldnote_account_deletion_request
--
CREATE TABLE "fieldnote_account_deletion_request" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "lastError" text,
    "attempts" bigint NOT NULL DEFAULT 0,
    "nextAttemptAt" timestamp without time zone,
    "requestedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" timestamp without time zone,
    "completedAt" timestamp without time zone,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_account_deletion_user_idx" ON "fieldnote_account_deletion_request" USING btree ("authUserId");
CREATE INDEX "fieldnote_account_deletion_status_idx" ON "fieldnote_account_deletion_request" USING btree ("status");

--
-- Class Asset as table fieldnote_asset
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
-- Class AuditEvent as table fieldnote_audit_event
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
CREATE INDEX "fieldnote_audit_actor_time_idx" ON "fieldnote_audit_event" USING btree ("actorAuthUserId", "occurredAt");

--
-- Class Campaign as table fieldnote_campaign
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
    "fundingGoal" double precision NOT NULL DEFAULT 0,
    "sponsoredAmount" double precision NOT NULL DEFAULT 0,
    "latitude" double precision NOT NULL DEFAULT 18.5204,
    "longitude" double precision NOT NULL DEFAULT 73.8567,
    "geofenceMeters" double precision NOT NULL DEFAULT 200,
    "volunteerCapacity" bigint NOT NULL DEFAULT 10,
    "minimumVolunteers" bigint NOT NULL DEFAULT 1,
    "eligibleVolunteers" bigint NOT NULL DEFAULT 0,
    "readinessState" text NOT NULL DEFAULT 'open'::text,
    "revision" bigint NOT NULL DEFAULT 0,
    "readinessCheckedAt" timestamp without time zone,
    "confirmedAt" timestamp without time zone,
    "decisionDueAt" timestamp without time zone,
    "postponedAt" timestamp without time zone,
    "cancelledAt" timestamp without time zone,
    "requiredSkills" text NOT NULL DEFAULT ''::text,
    "checklist" text NOT NULL DEFAULT ''::text,
    "evidenceInstructions" text NOT NULL DEFAULT ''::text,
    "tags" text NOT NULL DEFAULT ''::text,
    "aiGenerated" boolean NOT NULL DEFAULT false,
    "coverImagePath" text,
    "publishedAt" timestamp without time zone,
    "completedAt" timestamp without time zone,
    "shareSlug" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_campaign_organization_idx" ON "fieldnote_campaign" USING btree ("organizationId");
CREATE INDEX "fieldnote_campaign_status_starts_idx" ON "fieldnote_campaign" USING btree ("status", "startsAt");
CREATE INDEX "fieldnote_campaign_created_by_idx" ON "fieldnote_campaign" USING btree ("createdBy");
CREATE UNIQUE INDEX "fieldnote_campaign_share_slug_idx" ON "fieldnote_campaign" USING btree ("shareSlug");

--
-- Class CampaignInvitation as table fieldnote_campaign_invitation
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
-- Class CampaignParticipation as table fieldnote_campaign_participation
--
CREATE TABLE "fieldnote_campaign_participation" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "volunteerAuthUserId" uuid NOT NULL,
    "status" text NOT NULL,
    "confirmedRevision" bigint NOT NULL DEFAULT 0,
    "joinedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "checkedInAt" timestamp without time zone,
    "completedAt" timestamp without time zone,
    "checkInLatitude" double precision,
    "checkInLongitude" double precision,
    "checkInAccuracyMeters" double precision,
    "locationIntegrityStatus" text,
    "locationIntegrityReasons" text,
    "locationIsDemo" boolean NOT NULL DEFAULT false,
    "leftAt" timestamp without time zone,
    "resolvedAt" timestamp without time zone,
    "evidenceUploadPath" text,
    "aiAnalyzedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_participation_campaign_volunteer_idx" ON "fieldnote_campaign_participation" USING btree ("campaignId", "volunteerAuthUserId");
CREATE INDEX "fieldnote_participation_volunteer_idx" ON "fieldnote_campaign_participation" USING btree ("volunteerAuthUserId");

--
-- Class CampaignPost as table fieldnote_campaign_post
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
-- Class CompletionEvidence as table fieldnote_completion_evidence
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
    "locationIntegrityStatus" text NOT NULL DEFAULT 'verified'::text,
    "locationIntegrityReasons" text NOT NULL DEFAULT 'Location checks passed'::text,
    "locationIsDemo" boolean NOT NULL DEFAULT false,
    "moderationStatus" text NOT NULL DEFAULT 'passed'::text,
    "submittedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "aiGenerated" boolean NOT NULL DEFAULT true,
    "reviewState" text NOT NULL DEFAULT 'awaitingReview'::text,
    "reviewNote" text,
    "reviewedByAuthUserId" uuid,
    "reviewedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_evidence_participation_idx" ON "fieldnote_completion_evidence" USING btree ("participationId");

--
-- Class FollowUpTask as table fieldnote_follow_up_task
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
-- Class LegalConsent as table fieldnote_legal_consent
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
-- Class LegalConsentHistory as table fieldnote_legal_consent_history
--
CREATE TABLE "fieldnote_legal_consent_history" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "action" text NOT NULL,
    "privacyPolicyVersion" text NOT NULL,
    "termsVersion" text NOT NULL,
    "locationConsent" boolean NOT NULL,
    "aiProcessingConsent" boolean NOT NULL,
    "evidenceSharingConsent" boolean NOT NULL,
    "recordedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_consent_history_user_idx" ON "fieldnote_legal_consent_history" USING btree ("authUserId", "recordedAt");

--
-- Class NotificationOutbox as table fieldnote_notification_outbox
--
CREATE TABLE "fieldnote_notification_outbox" (
    "id" bigserial PRIMARY KEY,
    "recipientAuthUserId" uuid NOT NULL,
    "kind" text NOT NULL,
    "dedupeKey" text NOT NULL,
    "subject" text NOT NULL,
    "bodyText" text NOT NULL,
    "bodyHtml" text NOT NULL,
    "toEmail" text,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "attempts" bigint NOT NULL DEFAULT 0,
    "lastError" text,
    "nextAttemptAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_notification_dedupe_idx" ON "fieldnote_notification_outbox" USING btree ("recipientAuthUserId", "dedupeKey");
CREATE INDEX "fieldnote_notification_status_idx" ON "fieldnote_notification_outbox" USING btree ("status", "nextAttemptAt");

--
-- Class Observation as table fieldnote_observation
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
-- Class ObservationMedia as table fieldnote_observation_media
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
-- Class Organization as table fieldnote_organization
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
-- Class OrganizationMember as table fieldnote_organization_member
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
-- Class PaymentWebhookEvent as table fieldnote_payment_webhook_event
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
-- Class RateLimitBucket as table fieldnote_rate_limit_bucket
--
CREATE TABLE "fieldnote_rate_limit_bucket" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "action" text NOT NULL,
    "windowStart" timestamp without time zone NOT NULL,
    "hits" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_rate_limit_bucket_key_idx" ON "fieldnote_rate_limit_bucket" USING btree ("authUserId", "action", "windowStart");
CREATE INDEX "fieldnote_rate_limit_bucket_window_idx" ON "fieldnote_rate_limit_bucket" USING btree ("windowStart");

--
-- Class ReviewDecision as table fieldnote_review_decision
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
-- Class Sponsorship as table fieldnote_sponsorship
--
CREATE TABLE "fieldnote_sponsorship" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "sponsorAuthUserId" uuid NOT NULL,
    "amount" double precision NOT NULL,
    "message" text,
    "paymentProvider" text NOT NULL DEFAULT 'razorpay'::text,
    "paymentStatus" text NOT NULL DEFAULT 'created'::text,
    "providerOrderId" text,
    "providerPaymentId" text,
    "verifiedAt" timestamp without time zone,
    "failureReason" text,
    "reconcileAttempts" bigint NOT NULL DEFAULT 0,
    "lastReconciledAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_sponsorship_campaign_idx" ON "fieldnote_sponsorship" USING btree ("campaignId");
CREATE INDEX "fieldnote_sponsorship_campaign_status_idx" ON "fieldnote_sponsorship" USING btree ("campaignId", "paymentStatus");
CREATE INDEX "fieldnote_sponsorship_status_idx" ON "fieldnote_sponsorship" USING btree ("paymentStatus", "createdAt");
CREATE INDEX "fieldnote_sponsorship_sponsor_idx" ON "fieldnote_sponsorship" USING btree ("sponsorAuthUserId");
CREATE UNIQUE INDEX "fieldnote_sponsorship_provider_order_idx" ON "fieldnote_sponsorship" USING btree ("providerOrderId");

--
-- Class TestPayout as table fieldnote_test_payout
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
-- Class TestRefund as table fieldnote_test_refund
--
CREATE TABLE "fieldnote_test_refund" (
    "id" bigserial PRIMARY KEY,
    "campaignId" bigint NOT NULL,
    "sponsorshipId" bigint NOT NULL,
    "amount" double precision NOT NULL,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "reason" text NOT NULL DEFAULT 'campaign_cancelled'::text,
    "testMode" boolean NOT NULL DEFAULT true,
    "attempts" bigint NOT NULL DEFAULT 0,
    "providerRefundId" text,
    "lastError" text,
    "nextAttemptAt" timestamp without time zone,
    "processedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fieldnote_test_refund_campaign_idx" ON "fieldnote_test_refund" USING btree ("campaignId");
CREATE UNIQUE INDEX "fieldnote_test_refund_sponsorship_idx" ON "fieldnote_test_refund" USING btree ("sponsorshipId");
CREATE INDEX "fieldnote_test_refund_status_idx" ON "fieldnote_test_refund" USING btree ("status");

--
-- Class FieldnoteUserProfile as table fieldnote_user_profile
--
CREATE TABLE "fieldnote_user_profile" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "role" text NOT NULL,
    "displayName" text NOT NULL,
    "sponsorType" text,
    "organizationName" text,
    "contactPhone" text,
    "city" text NOT NULL,
    "locationAddress" text,
    "locationPlaceId" text,
    "locationLatitude" double precision,
    "locationLongitude" double precision,
    "interests" text NOT NULL,
    "skills" text NOT NULL,
    "emailNotifications" boolean NOT NULL DEFAULT true,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_user_profile__authUserId__unique_idx" ON "fieldnote_user_profile" USING btree ("authUserId");

--
-- Class VolunteerAvailability as table fieldnote_volunteer_availability
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
    "timezone" text,
    "utcOffsetMinutes" bigint,
    "availableTodayDate" text,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "fieldnote_volunteer_availability__volunte5714f5759f__unique_idx" ON "fieldnote_volunteer_availability" USING btree ("volunteerAuthUserId");

--
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- Class CloudStorageDirectDownloadEntry as table serverpod_cloud_storage_direct_download
--
CREATE TABLE "serverpod_cloud_storage_direct_download" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "downloadFileName" text,
    "contentType" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_download_auth_key" ON "serverpod_cloud_storage_direct_download" USING btree ("authKey");
CREATE INDEX "serverpod_cloud_storage_direct_download_expiration" ON "serverpod_cloud_storage_direct_download" USING btree ("expiration");

--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "maxFileSize" bigint NOT NULL DEFAULT 10485760,
    "contentLength" bigint,
    "preventOverwrite" boolean NOT NULL DEFAULT false,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text,
    "scheduling" json
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- Class FutureCallClaimEntry as table serverpod_future_call_claim
--
CREATE TABLE "serverpod_future_call_claim" (
    "id" bigserial PRIMARY KEY,
    "futureCallId" bigint,
    "lastHeartbeatTime" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "future_call_unique_idx" ON "serverpod_future_call_claim" USING btree ("futureCallId");

--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "active" bigint NOT NULL,
    "closing" bigint NOT NULL,
    "idle" bigint NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" USING btree ("timestamp", "serverId", "granularity");

--
-- Class ServerHealthMetric as table serverpod_health_metric
--
CREATE TABLE "serverpod_health_metric" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "isHealthy" boolean NOT NULL,
    "value" double precision NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" USING btree ("timestamp", "serverId", "name", "granularity");

--
-- Class LogEntry as table serverpod_log
--
CREATE TABLE "serverpod_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "reference" text,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "logLevel" bigint NOT NULL,
    "message" text NOT NULL,
    "error" text,
    "stackTrace" text,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId", "order");

--
-- Class MessageLogEntry as table serverpod_message_log
--
CREATE TABLE "serverpod_message_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "serverId" text NOT NULL,
    "messageId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "messageName" text NOT NULL,
    "duration" double precision NOT NULL,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_message_log_sessionLogId_idx" ON "serverpod_message_log" USING btree ("sessionLogId", "order");

--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- Class DatabaseMigrationVersion as table serverpod_migrations
--
CREATE TABLE "serverpod_migrations" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "version" text NOT NULL,
    "timestamp" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" USING btree ("module");

--
-- Class QueryLogEntry as table serverpod_query_log
--
CREATE TABLE "serverpod_query_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "query" text NOT NULL,
    "duration" double precision NOT NULL,
    "numRows" bigint,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId", "order");

--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- Class SessionLogEntry as table serverpod_session_log
--
CREATE TABLE "serverpod_session_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "module" text,
    "endpoint" text,
    "method" text,
    "duration" double precision,
    "numQueries" bigint,
    "slow" boolean,
    "error" text,
    "stackTrace" text,
    "authenticatedUserId" bigint,
    "userId" text,
    "isOpen" boolean,
    "touched" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" USING btree ("serverId");
CREATE INDEX "serverpod_session_log_time_idx" ON "serverpod_session_log" USING btree ("time");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" USING btree ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" USING btree ("isOpen");

--
-- Class AnonymousAccount as table serverpod_auth_idp_anonymous_account
--
CREATE TABLE "serverpod_auth_idp_anonymous_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- Class AppleAccount as table serverpod_auth_idp_apple_account
--
CREATE TABLE "serverpod_auth_idp_apple_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userIdentifier" text NOT NULL,
    "refreshToken" text NOT NULL,
    "refreshTokenRequestedWithBundleIdentifier" boolean NOT NULL,
    "lastRefreshedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "email" text,
    "isEmailVerified" boolean,
    "isPrivateEmail" boolean,
    "firstName" text,
    "lastName" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_apple_account_identifier" ON "serverpod_auth_idp_apple_account" USING btree ("userIdentifier");

--
-- Class EmailAccount as table serverpod_auth_idp_email_account
--
CREATE TABLE "serverpod_auth_idp_email_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "email" text NOT NULL,
    "passwordHash" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_email" ON "serverpod_auth_idp_email_account" USING btree ("email");

--
-- Class EmailAccountPasswordResetRequest as table serverpod_auth_idp_email_account_password_reset_request
--
CREATE TABLE "serverpod_auth_idp_email_account_password_reset_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "emailAccountId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "challengeId" uuid NOT NULL,
    "setPasswordChallengeId" uuid
);

--
-- Class EmailAccountRequest as table serverpod_auth_idp_email_account_request
--
CREATE TABLE "serverpod_auth_idp_email_account_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "email" text NOT NULL,
    "challengeId" uuid NOT NULL,
    "createAccountChallengeId" uuid
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_request_email" ON "serverpod_auth_idp_email_account_request" USING btree ("email");

--
-- Class FacebookAccount as table serverpod_auth_idp_facebook_account
--
CREATE TABLE "serverpod_auth_idp_facebook_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "fullName" text,
    "firstName" text,
    "lastName" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_facebook_account_user_identifier" ON "serverpod_auth_idp_facebook_account" USING btree ("userIdentifier");

--
-- Class FirebaseAccount as table serverpod_auth_idp_firebase_account
--
CREATE TABLE "serverpod_auth_idp_firebase_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "created" timestamp without time zone NOT NULL,
    "email" text,
    "phone" text,
    "userIdentifier" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_firebase_account_user_identifier" ON "serverpod_auth_idp_firebase_account" USING btree ("userIdentifier");

--
-- Class GitHubAccount as table serverpod_auth_idp_github_account
--
CREATE TABLE "serverpod_auth_idp_github_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "created" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_github_account_user_identifier" ON "serverpod_auth_idp_github_account" USING btree ("userIdentifier");

--
-- Class GoogleAccount as table serverpod_auth_idp_google_account
--
CREATE TABLE "serverpod_auth_idp_google_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "created" timestamp without time zone NOT NULL,
    "email" text NOT NULL,
    "userIdentifier" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_google_account_user_identifier" ON "serverpod_auth_idp_google_account" USING btree ("userIdentifier");

--
-- Class MicrosoftAccount as table serverpod_auth_idp_microsoft_account
--
CREATE TABLE "serverpod_auth_idp_microsoft_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "created" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_microsoft_account_user_identifier" ON "serverpod_auth_idp_microsoft_account" USING btree ("userIdentifier");

--
-- Class PasskeyAccount as table serverpod_auth_idp_passkey_account
--
CREATE TABLE "serverpod_auth_idp_passkey_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "keyId" bytea NOT NULL,
    "keyIdBase64" text NOT NULL,
    "clientDataJSON" bytea NOT NULL,
    "attestationObject" bytea NOT NULL,
    "originalChallenge" bytea NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_passkey_account_key_id_base64" ON "serverpod_auth_idp_passkey_account" USING btree ("keyIdBase64");

--
-- Class PasskeyChallenge as table serverpod_auth_idp_passkey_challenge
--
CREATE TABLE "serverpod_auth_idp_passkey_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "challenge" bytea NOT NULL
);

--
-- Class RateLimitedRequestAttempt as table serverpod_auth_idp_rate_limited_request_attempt
--
CREATE TABLE "serverpod_auth_idp_rate_limited_request_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "domain" text NOT NULL,
    "source" text NOT NULL,
    "key" text NOT NULL,
    "ipAddress" text,
    "attemptedAt" timestamp without time zone NOT NULL,
    "extraData" json
);

-- Indexes
CREATE INDEX "serverpod_auth_idp_rate_limited_request_attempt_composite" ON "serverpod_auth_idp_rate_limited_request_attempt" USING btree ("domain", "source", "key", "attemptedAt");

--
-- Class SecretChallenge as table serverpod_auth_idp_secret_challenge
--
CREATE TABLE "serverpod_auth_idp_secret_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "challengeCodeHash" text NOT NULL
);

--
-- Class RefreshToken as table serverpod_auth_core_jwt_refresh_token
--
CREATE TABLE "serverpod_auth_core_jwt_refresh_token" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "scopeNames" json NOT NULL,
    "extraClaims" text,
    "method" text NOT NULL,
    "fixedSecret" bytea NOT NULL,
    "rotatingSecretHash" text NOT NULL,
    "lastUpdatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "serverpod_auth_core_jwt_refresh_token_last_updated_at" ON "serverpod_auth_core_jwt_refresh_token" USING btree ("lastUpdatedAt");

--
-- Class UserProfile as table serverpod_auth_core_profile
--
CREATE TABLE "serverpod_auth_core_profile" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userName" text,
    "fullName" text,
    "email" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "imageId" uuid
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_profile_user_profile_email_auth_user_id" ON "serverpod_auth_core_profile" USING btree ("authUserId");

--
-- Class UserProfileImage as table serverpod_auth_core_profile_image
--
CREATE TABLE "serverpod_auth_core_profile_image" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userProfileId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "url" text NOT NULL
);

--
-- Class ServerSideSession as table serverpod_auth_core_session
--
CREATE TABLE "serverpod_auth_core_session" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "scopeNames" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone,
    "expireAfterUnusedFor" bigint,
    "sessionKeyHash" bytea NOT NULL,
    "sessionKeySalt" bytea NOT NULL,
    "method" text NOT NULL
);

--
-- Class AuthUser as table serverpod_auth_core_user
--
CREATE TABLE "serverpod_auth_core_user" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "scopeNames" json NOT NULL,
    "blocked" boolean NOT NULL
);

--
-- Foreign relations for "fieldnote_asset" table
--
ALTER TABLE ONLY "fieldnote_asset"
    ADD CONSTRAINT "fieldnote_asset_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_campaign" table
--
ALTER TABLE ONLY "fieldnote_campaign"
    ADD CONSTRAINT "fieldnote_campaign_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "fieldnote_organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_campaign_invitation" table
--
ALTER TABLE ONLY "fieldnote_campaign_invitation"
    ADD CONSTRAINT "fieldnote_campaign_invitation_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_campaign_participation" table
--
ALTER TABLE ONLY "fieldnote_campaign_participation"
    ADD CONSTRAINT "fieldnote_campaign_participation_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_campaign_post" table
--
ALTER TABLE ONLY "fieldnote_campaign_post"
    ADD CONSTRAINT "fieldnote_campaign_post_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_completion_evidence" table
--
ALTER TABLE ONLY "fieldnote_completion_evidence"
    ADD CONSTRAINT "fieldnote_completion_evidence_fk_0"
    FOREIGN KEY("participationId")
    REFERENCES "fieldnote_campaign_participation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_follow_up_task" table
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
-- Foreign relations for "fieldnote_observation" table
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
-- Foreign relations for "fieldnote_observation_media" table
--
ALTER TABLE ONLY "fieldnote_observation_media"
    ADD CONSTRAINT "fieldnote_observation_media_fk_0"
    FOREIGN KEY("observationId")
    REFERENCES "fieldnote_observation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_organization_member" table
--
ALTER TABLE ONLY "fieldnote_organization_member"
    ADD CONSTRAINT "fieldnote_organization_member_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "fieldnote_organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_review_decision" table
--
ALTER TABLE ONLY "fieldnote_review_decision"
    ADD CONSTRAINT "fieldnote_review_decision_fk_0"
    FOREIGN KEY("observationId")
    REFERENCES "fieldnote_observation"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_sponsorship" table
--
ALTER TABLE ONLY "fieldnote_sponsorship"
    ADD CONSTRAINT "fieldnote_sponsorship_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fieldnote_test_payout" table
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
-- Foreign relations for "fieldnote_test_refund" table
--
ALTER TABLE ONLY "fieldnote_test_refund"
    ADD CONSTRAINT "fieldnote_test_refund_fk_0"
    FOREIGN KEY("campaignId")
    REFERENCES "fieldnote_campaign"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "fieldnote_test_refund"
    ADD CONSTRAINT "fieldnote_test_refund_fk_1"
    FOREIGN KEY("sponsorshipId")
    REFERENCES "fieldnote_sponsorship"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_future_call_claim" table
--
ALTER TABLE ONLY "serverpod_future_call_claim"
    ADD CONSTRAINT "serverpod_future_call_claim_fk_0"
    FOREIGN KEY("futureCallId")
    REFERENCES "serverpod_future_call"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_log" table
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_message_log" table
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_query_log" table
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_anonymous_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_anonymous_account"
    ADD CONSTRAINT "serverpod_auth_idp_anonymous_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_apple_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_apple_account"
    ADD CONSTRAINT "serverpod_auth_idp_apple_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account_password_reset_request" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_0"
    FOREIGN KEY("emailAccountId")
    REFERENCES "serverpod_auth_idp_email_account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_1"
    FOREIGN KEY("challengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_2"
    FOREIGN KEY("setPasswordChallengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account_request" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_request_fk_0"
    FOREIGN KEY("challengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_request_fk_1"
    FOREIGN KEY("createAccountChallengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_facebook_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_facebook_account"
    ADD CONSTRAINT "serverpod_auth_idp_facebook_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_firebase_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_firebase_account"
    ADD CONSTRAINT "serverpod_auth_idp_firebase_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_github_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_github_account"
    ADD CONSTRAINT "serverpod_auth_idp_github_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_google_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_google_account"
    ADD CONSTRAINT "serverpod_auth_idp_google_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_microsoft_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_microsoft_account"
    ADD CONSTRAINT "serverpod_auth_idp_microsoft_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_passkey_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_passkey_account"
    ADD CONSTRAINT "serverpod_auth_idp_passkey_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_jwt_refresh_token" table
--
ALTER TABLE ONLY "serverpod_auth_core_jwt_refresh_token"
    ADD CONSTRAINT "serverpod_auth_core_jwt_refresh_token_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_profile" table
--
ALTER TABLE ONLY "serverpod_auth_core_profile"
    ADD CONSTRAINT "serverpod_auth_core_profile_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_core_profile"
    ADD CONSTRAINT "serverpod_auth_core_profile_fk_1"
    FOREIGN KEY("imageId")
    REFERENCES "serverpod_auth_core_profile_image"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_profile_image" table
--
ALTER TABLE ONLY "serverpod_auth_core_profile_image"
    ADD CONSTRAINT "serverpod_auth_core_profile_image_fk_0"
    FOREIGN KEY("userProfileId")
    REFERENCES "serverpod_auth_core_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_session" table
--
ALTER TABLE ONLY "serverpod_auth_core_session"
    ADD CONSTRAINT "serverpod_auth_core_session_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR fieldnotes
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('fieldnotes', '20261001143105843-compliance-notifications', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261001143105843-compliance-notifications', "timestamp" = now();

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
