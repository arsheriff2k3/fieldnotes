/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign.dart'
    as _iuzdi22u;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_invitation.dart'
    as _icudrue1;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_match.dart'
    as _i3ipc266;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_participation.dart'
    as _i363uv3e;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/campaign_post.dart'
    as _id4uw0jw;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/legal_consent_history.dart'
    as _iocrnsa2;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/participation_history_entry.dart'
    as _io1qzx7f;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/place_suggestion.dart'
    as _i18eudx8;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/sponsorship.dart'
    as _iwnubjux;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/sponsorship_history_entry.dart'
    as _ipfz3r0x;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/test_payout.dart'
    as _i1fp4tnr;
import 'package:fieldnotes_server/src/generated/fieldnotes/models/test_refund.dart'
    as _ingh9nb7;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'fieldnotes/models/account_deletion_request.dart' as _irc6gkwg;
import 'fieldnotes/models/account_role.dart' as _iwea5c8m;
import 'fieldnotes/models/ai_confidence.dart' as _icuvt3ro;
import 'fieldnotes/models/audit_event.dart' as _i3s6sm3e;
import 'fieldnotes/models/campaign.dart' as _imoyt016;
import 'fieldnotes/models/campaign_invitation.dart' as _ibb1uwag;
import 'fieldnotes/models/campaign_live_update.dart' as _ixbyjocu;
import 'fieldnotes/models/campaign_map_overview.dart' as _ia1ix8k0;
import 'fieldnotes/models/campaign_map_pin.dart' as _iaixb6xr;
import 'fieldnotes/models/campaign_match.dart' as _isbhm9y0;
import 'fieldnotes/models/campaign_participation.dart' as _i8osbdqi;
import 'fieldnotes/models/campaign_post.dart' as _iz4wi5fy;
import 'fieldnotes/models/campaign_proposal.dart' as _ibvzmbaz;
import 'fieldnotes/models/campaign_reach.dart' as _i22k3mw4;
import 'fieldnotes/models/campaign_status.dart' as _iyus928a;
import 'fieldnotes/models/campaign_volunteer_map.dart' as _ixxdko7q;
import 'fieldnotes/models/campaign_volunteer_map_member.dart' as _ioj4s0dr;
import 'fieldnotes/models/completion_evidence.dart' as _i8shrtkg;
import 'fieldnotes/models/completion_proposal.dart' as _i60r3uxn;
import 'fieldnotes/models/dashboard_metrics.dart' as _iq1f4h1t;
import 'fieldnotes/models/fieldnote_exception.dart' as _ilzgaptr;
import 'fieldnotes/models/impact_summary.dart' as _i1e0rn9l;
import 'fieldnotes/models/legal_consent.dart' as _i6gdlup3;
import 'fieldnotes/models/legal_consent_history.dart' as _i36vuf99;
import 'fieldnotes/models/legal_policies.dart' as _ibf5kqr1;
import 'fieldnotes/models/notification_outbox.dart' as _i2sc5phg;
import 'fieldnotes/models/observation_condition.dart' as _ildc7cij;
import 'fieldnotes/models/observation_input.dart' as _i1u7gykm;
import 'fieldnotes/models/observation_proposal.dart' as _i805ku85;
import 'fieldnotes/models/organization.dart' as _if13xums;
import 'fieldnotes/models/participation_history_entry.dart' as _iu1h8z2d;
import 'fieldnotes/models/participation_status.dart' as _imreqlyp;
import 'fieldnotes/models/payment_webhook_event.dart' as _i6oivzdq;
import 'fieldnotes/models/place_suggestion.dart' as _i3jo3ess;
import 'fieldnotes/models/rate_limit_bucket.dart' as _igkrjajj;
import 'fieldnotes/models/razorpay_checkout_order.dart' as _iuc10yd2;
import 'fieldnotes/models/reach_cell.dart' as _il88if3j;
import 'fieldnotes/models/resolved_place.dart' as _illv04vj;
import 'fieldnotes/models/review_state.dart' as _iulscgnl;
import 'fieldnotes/models/sponsorship.dart' as _i1cgh9io;
import 'fieldnotes/models/sponsorship_history_entry.dart' as _ihlsdeis;
import 'fieldnotes/models/test_payout.dart' as _ibdacauq;
import 'fieldnotes/models/test_refund.dart' as _iviseq0a;
import 'fieldnotes/models/travel_route.dart' as _it2sjc8r;
import 'fieldnotes/models/travel_step.dart' as _ik5r1rtc;
import 'fieldnotes/models/trust_center_summary.dart' as _ip0a93i5;
import 'fieldnotes/models/user_profile.dart' as _iq3hh8xc;
import 'fieldnotes/models/volunteer_availability.dart' as _ifa4ljot;
export 'fieldnotes/models/account_deletion_request.dart';
export 'fieldnotes/models/account_role.dart';
export 'fieldnotes/models/ai_confidence.dart';
export 'fieldnotes/models/audit_event.dart';
export 'fieldnotes/models/campaign.dart';
export 'fieldnotes/models/campaign_invitation.dart';
export 'fieldnotes/models/campaign_live_update.dart';
export 'fieldnotes/models/campaign_map_overview.dart';
export 'fieldnotes/models/campaign_map_pin.dart';
export 'fieldnotes/models/campaign_match.dart';
export 'fieldnotes/models/campaign_participation.dart';
export 'fieldnotes/models/campaign_post.dart';
export 'fieldnotes/models/campaign_proposal.dart';
export 'fieldnotes/models/campaign_reach.dart';
export 'fieldnotes/models/campaign_status.dart';
export 'fieldnotes/models/campaign_volunteer_map.dart';
export 'fieldnotes/models/campaign_volunteer_map_member.dart';
export 'fieldnotes/models/completion_evidence.dart';
export 'fieldnotes/models/completion_proposal.dart';
export 'fieldnotes/models/dashboard_metrics.dart';
export 'fieldnotes/models/fieldnote_exception.dart';
export 'fieldnotes/models/impact_summary.dart';
export 'fieldnotes/models/legal_consent.dart';
export 'fieldnotes/models/legal_consent_history.dart';
export 'fieldnotes/models/legal_policies.dart';
export 'fieldnotes/models/notification_outbox.dart';
export 'fieldnotes/models/observation_condition.dart';
export 'fieldnotes/models/observation_input.dart';
export 'fieldnotes/models/observation_proposal.dart';
export 'fieldnotes/models/organization.dart';
export 'fieldnotes/models/participation_history_entry.dart';
export 'fieldnotes/models/participation_status.dart';
export 'fieldnotes/models/payment_webhook_event.dart';
export 'fieldnotes/models/place_suggestion.dart';
export 'fieldnotes/models/rate_limit_bucket.dart';
export 'fieldnotes/models/razorpay_checkout_order.dart';
export 'fieldnotes/models/reach_cell.dart';
export 'fieldnotes/models/resolved_place.dart';
export 'fieldnotes/models/review_state.dart';
export 'fieldnotes/models/sponsorship.dart';
export 'fieldnotes/models/sponsorship_history_entry.dart';
export 'fieldnotes/models/test_payout.dart';
export 'fieldnotes/models/test_refund.dart';
export 'fieldnotes/models/travel_route.dart';
export 'fieldnotes/models/travel_step.dart';
export 'fieldnotes/models/trust_center_summary.dart';
export 'fieldnotes/models/user_profile.dart';
export 'fieldnotes/models/volunteer_availability.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'fieldnote_account_deletion_request',
      dartName: 'AccountDeletionRequest',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'lastError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'attempts',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'nextAttemptAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'requestedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'processedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'completedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_account_deletion_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_account_deletion_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_audit_event',
      dartName: 'AuditEvent',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'actorAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'event',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'entityType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'riskLevel',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'detail',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'occurredAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_audit_actor_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'actorAuthUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_audit_actor_time_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'actorAuthUserId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'occurredAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_campaign',
      dartName: 'Campaign',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'organizationId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'locationName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'startsAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'endsAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CampaignStatus',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'fundingGoal',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'sponsoredAmount',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'fundingGoalPaise',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'sponsoredAmountPaise',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'refundedAmountPaise',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'latitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '18.5204',
        ),
        _isp.ColumnDefinition(
          name: 'longitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '73.8567',
        ),
        _isp.ColumnDefinition(
          name: 'geofenceMeters',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
          columnDefault: '200',
        ),
        _isp.ColumnDefinition(
          name: 'volunteerCapacity',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '10',
        ),
        _isp.ColumnDefinition(
          name: 'minimumVolunteers',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'eligibleVolunteers',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'readinessState',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'open\'',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'readinessCheckedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'confirmedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'decisionDueAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'postponedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'cancelledAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'requiredSkills',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'checklist',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'evidenceInstructions',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'tags',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'aiGenerated',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'coverImagePath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'publishedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'completedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'shareSlug',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'clientRequestId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_campaign_fk_0',
          columns: ['organizationId'],
          referenceTable: 'fieldnote_organization',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_campaign_organization_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'organizationId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_campaign_status_starts_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'startsAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_campaign_created_by_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdBy',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_campaign_share_slug_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'shareSlug',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_campaign_client_request_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdBy',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'clientRequestId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_campaign_invitation',
      dartName: 'CampaignInvitation',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'campaignId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'volunteerAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sponsorAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_campaign_invitation_fk_0',
          columns: ['campaignId'],
          referenceTable: 'fieldnote_campaign',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_invitation_campaign_volunteer_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'campaignId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'volunteerAuthUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_invitation_volunteer_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'volunteerAuthUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_campaign_participation',
      dartName: 'CampaignParticipation',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'campaignId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'volunteerAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ParticipationStatus',
        ),
        _isp.ColumnDefinition(
          name: 'confirmedRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'checkedInAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'completedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'checkInLatitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'checkInLongitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'checkInAccuracyMeters',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'locationIntegrityStatus',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'locationIntegrityReasons',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'locationIsDemo',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'leftAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'resolvedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'evidenceUploadPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'aiAnalyzedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_campaign_participation_fk_0',
          columns: ['campaignId'],
          referenceTable: 'fieldnote_campaign',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_participation_campaign_volunteer_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'campaignId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'volunteerAuthUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_participation_volunteer_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'volunteerAuthUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_campaign_post',
      dartName: 'CampaignPost',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'campaignId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'authorSponsorAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'body',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'photographPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_campaign_post_fk_0',
          columns: ['campaignId'],
          referenceTable: 'fieldnote_campaign',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_post_campaign_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'campaignId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_completion_evidence',
      dartName: 'CompletionEvidence',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'participationId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'photographPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'originalNote',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'confirmedSummary',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'structuredResults',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'latitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'longitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'locationAccuracyMeters',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'locationIntegrityStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'verified\'',
        ),
        _isp.ColumnDefinition(
          name: 'locationIntegrityReasons',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'Location checks passed\'',
        ),
        _isp.ColumnDefinition(
          name: 'locationIsDemo',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'moderationStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'passed\'',
        ),
        _isp.ColumnDefinition(
          name: 'submittedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'aiGenerated',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'reviewState',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ReviewState',
          columnDefault: '\'awaitingReview\'',
        ),
        _isp.ColumnDefinition(
          name: 'reviewNote',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'reviewedByAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'reviewedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_completion_evidence_fk_0',
          columns: ['participationId'],
          referenceTable: 'fieldnote_campaign_participation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_evidence_participation_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'participationId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_legal_consent',
      dartName: 'LegalConsent',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'privacyPolicyVersion',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'termsVersion',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'locationConsent',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'aiProcessingConsent',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'evidenceSharingConsent',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'acceptedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_legal_consent__authUserId__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_legal_consent_history',
      dartName: 'LegalConsentHistory',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'action',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'privacyPolicyVersion',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'termsVersion',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'locationConsent',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'aiProcessingConsent',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'evidenceSharingConsent',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'recordedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_consent_history_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recordedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_notification_outbox',
      dartName: 'NotificationOutbox',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'recipientAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'dedupeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'subject',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'bodyText',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'bodyHtml',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'toEmail',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'attempts',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'lastError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'nextAttemptAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'sentAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_notification_dedupe_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientAuthUserId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'dedupeKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_notification_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nextAttemptAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_organization',
      dartName: 'Organization',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_organization_name_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_payment_webhook_event',
      dartName: 'PaymentWebhookEvent',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'provider',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'razorpay\'',
        ),
        _isp.ColumnDefinition(
          name: 'eventId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'eventType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payloadSha256',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'received\'',
        ),
        _isp.ColumnDefinition(
          name: 'detail',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'attempts',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'receivedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'processedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_payment_webhook_event_id_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'provider',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_rate_limit_bucket',
      dartName: 'RateLimitBucket',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'action',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'windowStart',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'hits',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_rate_limit_bucket_key_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'action',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'windowStart',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_rate_limit_bucket_window_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'windowStart',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_sponsorship',
      dartName: 'Sponsorship',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'campaignId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sponsorAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'amount',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'amountPaise',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'message',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'paymentProvider',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'razorpay\'',
        ),
        _isp.ColumnDefinition(
          name: 'paymentStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'created\'',
        ),
        _isp.ColumnDefinition(
          name: 'providerOrderId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'providerPaymentId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'verifiedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'failureReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'reconcileAttempts',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'lastReconciledAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'clientRequestId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_sponsorship_fk_0',
          columns: ['campaignId'],
          referenceTable: 'fieldnote_campaign',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_sponsorship_campaign_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'campaignId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_sponsorship_campaign_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'campaignId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'paymentStatus',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_sponsorship_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'paymentStatus',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_sponsorship_sponsor_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sponsorAuthUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_sponsorship_provider_order_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'providerOrderId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_sponsorship_client_request_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sponsorAuthUserId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'clientRequestId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_test_payout',
      dartName: 'TestPayout',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'campaignId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sponsorshipId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'creatorAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'amount',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'amountPaise',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'sourcePaymentId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'simulated\'',
        ),
        _isp.ColumnDefinition(
          name: 'simulatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_test_payout_fk_0',
          columns: ['campaignId'],
          referenceTable: 'fieldnote_campaign',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_test_payout_fk_1',
          columns: ['sponsorshipId'],
          referenceTable: 'fieldnote_sponsorship',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_test_payout_campaign_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'campaignId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_test_payout_sponsorship_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sponsorshipId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_test_refund',
      dartName: 'TestRefund',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'campaignId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sponsorshipId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'amount',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'amountPaise',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'campaign_cancelled\'',
        ),
        _isp.ColumnDefinition(
          name: 'testMode',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'attempts',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'providerRefundId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'lastError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'nextAttemptAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'processedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'fundingReversedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'fundingReversedPaise',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_test_refund_fk_0',
          columns: ['campaignId'],
          referenceTable: 'fieldnote_campaign',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'fieldnote_test_refund_fk_1',
          columns: ['sponsorshipId'],
          referenceTable: 'fieldnote_sponsorship',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_test_refund_campaign_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'campaignId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_test_refund_sponsorship_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sponsorshipId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'fieldnote_test_refund_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_user_profile',
      dartName: 'FieldnoteUserProfile',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AccountRole',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sponsorType',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'organizationName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'contactPhone',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'city',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'locationAddress',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'locationPlaceId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'locationLatitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'locationLongitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'interests',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'skills',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'emailNotifications',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'fieldnote_user_profile__authUserId__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'fieldnote_volunteer_availability',
      dartName: 'VolunteerAvailability',
      schema: 'public',
      module: 'fieldnotes',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'volunteerAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'isAvailable',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'availableToday',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'weekdays',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'startMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'endMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'maximumTravelKm',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'latitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'longitude',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'locationLabel',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'timezone',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'utcOffsetMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'availableTodayDate',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName:
              'fieldnote_volunteer_availability__volunte5714f5759f__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'volunteerAuthUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _irc6gkwg.AccountDeletionRequest) {
      return _irc6gkwg.AccountDeletionRequest.fromJson(data) as T;
    }
    if (t == _iwea5c8m.AccountRole) {
      return _iwea5c8m.AccountRole.fromJson(data) as T;
    }
    if (t == _icuvt3ro.AiConfidence) {
      return _icuvt3ro.AiConfidence.fromJson(data) as T;
    }
    if (t == _i3s6sm3e.AuditEvent) {
      return _i3s6sm3e.AuditEvent.fromJson(data) as T;
    }
    if (t == _imoyt016.Campaign) {
      return _imoyt016.Campaign.fromJson(data) as T;
    }
    if (t == _ibb1uwag.CampaignInvitation) {
      return _ibb1uwag.CampaignInvitation.fromJson(data) as T;
    }
    if (t == _ixbyjocu.CampaignLiveUpdate) {
      return _ixbyjocu.CampaignLiveUpdate.fromJson(data) as T;
    }
    if (t == _ia1ix8k0.CampaignMapOverview) {
      return _ia1ix8k0.CampaignMapOverview.fromJson(data) as T;
    }
    if (t == _iaixb6xr.CampaignMapPin) {
      return _iaixb6xr.CampaignMapPin.fromJson(data) as T;
    }
    if (t == _isbhm9y0.CampaignMatch) {
      return _isbhm9y0.CampaignMatch.fromJson(data) as T;
    }
    if (t == _i8osbdqi.CampaignParticipation) {
      return _i8osbdqi.CampaignParticipation.fromJson(data) as T;
    }
    if (t == _iz4wi5fy.CampaignPost) {
      return _iz4wi5fy.CampaignPost.fromJson(data) as T;
    }
    if (t == _ibvzmbaz.CampaignProposal) {
      return _ibvzmbaz.CampaignProposal.fromJson(data) as T;
    }
    if (t == _i22k3mw4.CampaignReach) {
      return _i22k3mw4.CampaignReach.fromJson(data) as T;
    }
    if (t == _iyus928a.CampaignStatus) {
      return _iyus928a.CampaignStatus.fromJson(data) as T;
    }
    if (t == _ixxdko7q.CampaignVolunteerMap) {
      return _ixxdko7q.CampaignVolunteerMap.fromJson(data) as T;
    }
    if (t == _ioj4s0dr.CampaignVolunteerMapMember) {
      return _ioj4s0dr.CampaignVolunteerMapMember.fromJson(data) as T;
    }
    if (t == _i8shrtkg.CompletionEvidence) {
      return _i8shrtkg.CompletionEvidence.fromJson(data) as T;
    }
    if (t == _i60r3uxn.CompletionProposal) {
      return _i60r3uxn.CompletionProposal.fromJson(data) as T;
    }
    if (t == _iq1f4h1t.DashboardMetrics) {
      return _iq1f4h1t.DashboardMetrics.fromJson(data) as T;
    }
    if (t == _ilzgaptr.FieldnoteException) {
      return _ilzgaptr.FieldnoteException.fromJson(data) as T;
    }
    if (t == _i1e0rn9l.ImpactSummary) {
      return _i1e0rn9l.ImpactSummary.fromJson(data) as T;
    }
    if (t == _i6gdlup3.LegalConsent) {
      return _i6gdlup3.LegalConsent.fromJson(data) as T;
    }
    if (t == _i36vuf99.LegalConsentHistory) {
      return _i36vuf99.LegalConsentHistory.fromJson(data) as T;
    }
    if (t == _ibf5kqr1.LegalPolicies) {
      return _ibf5kqr1.LegalPolicies.fromJson(data) as T;
    }
    if (t == _i2sc5phg.NotificationOutbox) {
      return _i2sc5phg.NotificationOutbox.fromJson(data) as T;
    }
    if (t == _ildc7cij.ObservationCondition) {
      return _ildc7cij.ObservationCondition.fromJson(data) as T;
    }
    if (t == _i1u7gykm.ObservationInput) {
      return _i1u7gykm.ObservationInput.fromJson(data) as T;
    }
    if (t == _i805ku85.ObservationProposal) {
      return _i805ku85.ObservationProposal.fromJson(data) as T;
    }
    if (t == _if13xums.Organization) {
      return _if13xums.Organization.fromJson(data) as T;
    }
    if (t == _iu1h8z2d.ParticipationHistoryEntry) {
      return _iu1h8z2d.ParticipationHistoryEntry.fromJson(data) as T;
    }
    if (t == _imreqlyp.ParticipationStatus) {
      return _imreqlyp.ParticipationStatus.fromJson(data) as T;
    }
    if (t == _i6oivzdq.PaymentWebhookEvent) {
      return _i6oivzdq.PaymentWebhookEvent.fromJson(data) as T;
    }
    if (t == _i3jo3ess.PlaceSuggestion) {
      return _i3jo3ess.PlaceSuggestion.fromJson(data) as T;
    }
    if (t == _igkrjajj.RateLimitBucket) {
      return _igkrjajj.RateLimitBucket.fromJson(data) as T;
    }
    if (t == _iuc10yd2.RazorpayCheckoutOrder) {
      return _iuc10yd2.RazorpayCheckoutOrder.fromJson(data) as T;
    }
    if (t == _il88if3j.ReachCell) {
      return _il88if3j.ReachCell.fromJson(data) as T;
    }
    if (t == _illv04vj.ResolvedPlace) {
      return _illv04vj.ResolvedPlace.fromJson(data) as T;
    }
    if (t == _iulscgnl.ReviewState) {
      return _iulscgnl.ReviewState.fromJson(data) as T;
    }
    if (t == _i1cgh9io.Sponsorship) {
      return _i1cgh9io.Sponsorship.fromJson(data) as T;
    }
    if (t == _ihlsdeis.SponsorshipHistoryEntry) {
      return _ihlsdeis.SponsorshipHistoryEntry.fromJson(data) as T;
    }
    if (t == _ibdacauq.TestPayout) {
      return _ibdacauq.TestPayout.fromJson(data) as T;
    }
    if (t == _iviseq0a.TestRefund) {
      return _iviseq0a.TestRefund.fromJson(data) as T;
    }
    if (t == _it2sjc8r.TravelRoute) {
      return _it2sjc8r.TravelRoute.fromJson(data) as T;
    }
    if (t == _ik5r1rtc.TravelStep) {
      return _ik5r1rtc.TravelStep.fromJson(data) as T;
    }
    if (t == _ip0a93i5.TrustCenterSummary) {
      return _ip0a93i5.TrustCenterSummary.fromJson(data) as T;
    }
    if (t == _iq3hh8xc.FieldnoteUserProfile) {
      return _iq3hh8xc.FieldnoteUserProfile.fromJson(data) as T;
    }
    if (t == _ifa4ljot.VolunteerAvailability) {
      return _ifa4ljot.VolunteerAvailability.fromJson(data) as T;
    }
    if (t == _is.getType<_irc6gkwg.AccountDeletionRequest?>()) {
      return (data != null
              ? _irc6gkwg.AccountDeletionRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwea5c8m.AccountRole?>()) {
      return (data != null ? _iwea5c8m.AccountRole.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_icuvt3ro.AiConfidence?>()) {
      return (data != null ? _icuvt3ro.AiConfidence.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3s6sm3e.AuditEvent?>()) {
      return (data != null ? _i3s6sm3e.AuditEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_imoyt016.Campaign?>()) {
      return (data != null ? _imoyt016.Campaign.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ibb1uwag.CampaignInvitation?>()) {
      return (data != null ? _ibb1uwag.CampaignInvitation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixbyjocu.CampaignLiveUpdate?>()) {
      return (data != null ? _ixbyjocu.CampaignLiveUpdate.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ia1ix8k0.CampaignMapOverview?>()) {
      return (data != null
              ? _ia1ix8k0.CampaignMapOverview.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iaixb6xr.CampaignMapPin?>()) {
      return (data != null ? _iaixb6xr.CampaignMapPin.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_isbhm9y0.CampaignMatch?>()) {
      return (data != null ? _isbhm9y0.CampaignMatch.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8osbdqi.CampaignParticipation?>()) {
      return (data != null
              ? _i8osbdqi.CampaignParticipation.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iz4wi5fy.CampaignPost?>()) {
      return (data != null ? _iz4wi5fy.CampaignPost.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ibvzmbaz.CampaignProposal?>()) {
      return (data != null ? _ibvzmbaz.CampaignProposal.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i22k3mw4.CampaignReach?>()) {
      return (data != null ? _i22k3mw4.CampaignReach.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iyus928a.CampaignStatus?>()) {
      return (data != null ? _iyus928a.CampaignStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixxdko7q.CampaignVolunteerMap?>()) {
      return (data != null
              ? _ixxdko7q.CampaignVolunteerMap.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ioj4s0dr.CampaignVolunteerMapMember?>()) {
      return (data != null
              ? _ioj4s0dr.CampaignVolunteerMapMember.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i8shrtkg.CompletionEvidence?>()) {
      return (data != null ? _i8shrtkg.CompletionEvidence.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i60r3uxn.CompletionProposal?>()) {
      return (data != null ? _i60r3uxn.CompletionProposal.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iq1f4h1t.DashboardMetrics?>()) {
      return (data != null ? _iq1f4h1t.DashboardMetrics.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilzgaptr.FieldnoteException?>()) {
      return (data != null ? _ilzgaptr.FieldnoteException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i1e0rn9l.ImpactSummary?>()) {
      return (data != null ? _i1e0rn9l.ImpactSummary.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i6gdlup3.LegalConsent?>()) {
      return (data != null ? _i6gdlup3.LegalConsent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i36vuf99.LegalConsentHistory?>()) {
      return (data != null
              ? _i36vuf99.LegalConsentHistory.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ibf5kqr1.LegalPolicies?>()) {
      return (data != null ? _ibf5kqr1.LegalPolicies.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i2sc5phg.NotificationOutbox?>()) {
      return (data != null ? _i2sc5phg.NotificationOutbox.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ildc7cij.ObservationCondition?>()) {
      return (data != null
              ? _ildc7cij.ObservationCondition.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i1u7gykm.ObservationInput?>()) {
      return (data != null ? _i1u7gykm.ObservationInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i805ku85.ObservationProposal?>()) {
      return (data != null
              ? _i805ku85.ObservationProposal.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_if13xums.Organization?>()) {
      return (data != null ? _if13xums.Organization.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iu1h8z2d.ParticipationHistoryEntry?>()) {
      return (data != null
              ? _iu1h8z2d.ParticipationHistoryEntry.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_imreqlyp.ParticipationStatus?>()) {
      return (data != null
              ? _imreqlyp.ParticipationStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6oivzdq.PaymentWebhookEvent?>()) {
      return (data != null
              ? _i6oivzdq.PaymentWebhookEvent.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3jo3ess.PlaceSuggestion?>()) {
      return (data != null ? _i3jo3ess.PlaceSuggestion.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igkrjajj.RateLimitBucket?>()) {
      return (data != null ? _igkrjajj.RateLimitBucket.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iuc10yd2.RazorpayCheckoutOrder?>()) {
      return (data != null
              ? _iuc10yd2.RazorpayCheckoutOrder.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_il88if3j.ReachCell?>()) {
      return (data != null ? _il88if3j.ReachCell.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_illv04vj.ResolvedPlace?>()) {
      return (data != null ? _illv04vj.ResolvedPlace.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iulscgnl.ReviewState?>()) {
      return (data != null ? _iulscgnl.ReviewState.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i1cgh9io.Sponsorship?>()) {
      return (data != null ? _i1cgh9io.Sponsorship.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ihlsdeis.SponsorshipHistoryEntry?>()) {
      return (data != null
              ? _ihlsdeis.SponsorshipHistoryEntry.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ibdacauq.TestPayout?>()) {
      return (data != null ? _ibdacauq.TestPayout.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iviseq0a.TestRefund?>()) {
      return (data != null ? _iviseq0a.TestRefund.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_it2sjc8r.TravelRoute?>()) {
      return (data != null ? _it2sjc8r.TravelRoute.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ik5r1rtc.TravelStep?>()) {
      return (data != null ? _ik5r1rtc.TravelStep.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ip0a93i5.TrustCenterSummary?>()) {
      return (data != null ? _ip0a93i5.TrustCenterSummary.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iq3hh8xc.FieldnoteUserProfile?>()) {
      return (data != null
              ? _iq3hh8xc.FieldnoteUserProfile.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ifa4ljot.VolunteerAvailability?>()) {
      return (data != null
              ? _ifa4ljot.VolunteerAvailability.fromJson(data)
              : null)
          as T;
    }
    if (t == List<_iaixb6xr.CampaignMapPin>) {
      return (data as List)
              .map((e) => deserialize<_iaixb6xr.CampaignMapPin>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_il88if3j.ReachCell>) {
      return (data as List)
              .map((e) => deserialize<_il88if3j.ReachCell>(e))
              .toList()
          as T;
    }
    if (t == List<_ioj4s0dr.CampaignVolunteerMapMember>) {
      return (data as List)
              .map((e) => deserialize<_ioj4s0dr.CampaignVolunteerMapMember>(e))
              .toList()
          as T;
    }
    if (t == List<_i8shrtkg.CompletionEvidence>) {
      return (data as List)
              .map((e) => deserialize<_i8shrtkg.CompletionEvidence>(e))
              .toList()
          as T;
    }
    if (t == List<_ik5r1rtc.TravelStep>) {
      return (data as List)
              .map((e) => deserialize<_ik5r1rtc.TravelStep>(e))
              .toList()
          as T;
    }
    if (t == List<_i3s6sm3e.AuditEvent>) {
      return (data as List)
              .map((e) => deserialize<_i3s6sm3e.AuditEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_iocrnsa2.LegalConsentHistory>) {
      return (data as List)
              .map((e) => deserialize<_iocrnsa2.LegalConsentHistory>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_iuzdi22u.Campaign>) {
      return (data as List)
              .map((e) => deserialize<_iuzdi22u.Campaign>(e))
              .toList()
          as T;
    }
    if (t == List<_i18eudx8.PlaceSuggestion>) {
      return (data as List)
              .map((e) => deserialize<_i18eudx8.PlaceSuggestion>(e))
              .toList()
          as T;
    }
    if (t == List<_icudrue1.CampaignInvitation>) {
      return (data as List)
              .map((e) => deserialize<_icudrue1.CampaignInvitation>(e))
              .toList()
          as T;
    }
    if (t == List<_iwnubjux.Sponsorship>) {
      return (data as List)
              .map((e) => deserialize<_iwnubjux.Sponsorship>(e))
              .toList()
          as T;
    }
    if (t == List<_i1fp4tnr.TestPayout>) {
      return (data as List)
              .map((e) => deserialize<_i1fp4tnr.TestPayout>(e))
              .toList()
          as T;
    }
    if (t == List<_i3ipc266.CampaignMatch>) {
      return (data as List)
              .map((e) => deserialize<_i3ipc266.CampaignMatch>(e))
              .toList()
          as T;
    }
    if (t == List<_i363uv3e.CampaignParticipation>) {
      return (data as List)
              .map((e) => deserialize<_i363uv3e.CampaignParticipation>(e))
              .toList()
          as T;
    }
    if (t == List<_ipfz3r0x.SponsorshipHistoryEntry>) {
      return (data as List)
              .map((e) => deserialize<_ipfz3r0x.SponsorshipHistoryEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_io1qzx7f.ParticipationHistoryEntry>) {
      return (data as List)
              .map((e) => deserialize<_io1qzx7f.ParticipationHistoryEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_ingh9nb7.TestRefund>) {
      return (data as List)
              .map((e) => deserialize<_ingh9nb7.TestRefund>(e))
              .toList()
          as T;
    }
    if (t == List<_id4uw0jw.CampaignPost>) {
      return (data as List)
              .map((e) => deserialize<_id4uw0jw.CampaignPost>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _irc6gkwg.AccountDeletionRequest => 'AccountDeletionRequest',
      _iwea5c8m.AccountRole => 'AccountRole',
      _icuvt3ro.AiConfidence => 'AiConfidence',
      _i3s6sm3e.AuditEvent => 'AuditEvent',
      _imoyt016.Campaign => 'Campaign',
      _ibb1uwag.CampaignInvitation => 'CampaignInvitation',
      _ixbyjocu.CampaignLiveUpdate => 'CampaignLiveUpdate',
      _ia1ix8k0.CampaignMapOverview => 'CampaignMapOverview',
      _iaixb6xr.CampaignMapPin => 'CampaignMapPin',
      _isbhm9y0.CampaignMatch => 'CampaignMatch',
      _i8osbdqi.CampaignParticipation => 'CampaignParticipation',
      _iz4wi5fy.CampaignPost => 'CampaignPost',
      _ibvzmbaz.CampaignProposal => 'CampaignProposal',
      _i22k3mw4.CampaignReach => 'CampaignReach',
      _iyus928a.CampaignStatus => 'CampaignStatus',
      _ixxdko7q.CampaignVolunteerMap => 'CampaignVolunteerMap',
      _ioj4s0dr.CampaignVolunteerMapMember => 'CampaignVolunteerMapMember',
      _i8shrtkg.CompletionEvidence => 'CompletionEvidence',
      _i60r3uxn.CompletionProposal => 'CompletionProposal',
      _iq1f4h1t.DashboardMetrics => 'DashboardMetrics',
      _ilzgaptr.FieldnoteException => 'FieldnoteException',
      _i1e0rn9l.ImpactSummary => 'ImpactSummary',
      _i6gdlup3.LegalConsent => 'LegalConsent',
      _i36vuf99.LegalConsentHistory => 'LegalConsentHistory',
      _ibf5kqr1.LegalPolicies => 'LegalPolicies',
      _i2sc5phg.NotificationOutbox => 'NotificationOutbox',
      _ildc7cij.ObservationCondition => 'ObservationCondition',
      _i1u7gykm.ObservationInput => 'ObservationInput',
      _i805ku85.ObservationProposal => 'ObservationProposal',
      _if13xums.Organization => 'Organization',
      _iu1h8z2d.ParticipationHistoryEntry => 'ParticipationHistoryEntry',
      _imreqlyp.ParticipationStatus => 'ParticipationStatus',
      _i6oivzdq.PaymentWebhookEvent => 'PaymentWebhookEvent',
      _i3jo3ess.PlaceSuggestion => 'PlaceSuggestion',
      _igkrjajj.RateLimitBucket => 'RateLimitBucket',
      _iuc10yd2.RazorpayCheckoutOrder => 'RazorpayCheckoutOrder',
      _il88if3j.ReachCell => 'ReachCell',
      _illv04vj.ResolvedPlace => 'ResolvedPlace',
      _iulscgnl.ReviewState => 'ReviewState',
      _i1cgh9io.Sponsorship => 'Sponsorship',
      _ihlsdeis.SponsorshipHistoryEntry => 'SponsorshipHistoryEntry',
      _ibdacauq.TestPayout => 'TestPayout',
      _iviseq0a.TestRefund => 'TestRefund',
      _it2sjc8r.TravelRoute => 'TravelRoute',
      _ik5r1rtc.TravelStep => 'TravelStep',
      _ip0a93i5.TrustCenterSummary => 'TrustCenterSummary',
      _iq3hh8xc.FieldnoteUserProfile => 'FieldnoteUserProfile',
      _ifa4ljot.VolunteerAvailability => 'VolunteerAvailability',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('fieldnotes.', '');
    }

    switch (data) {
      case _irc6gkwg.AccountDeletionRequest():
        return 'AccountDeletionRequest';
      case _iwea5c8m.AccountRole():
        return 'AccountRole';
      case _icuvt3ro.AiConfidence():
        return 'AiConfidence';
      case _i3s6sm3e.AuditEvent():
        return 'AuditEvent';
      case _imoyt016.Campaign():
        return 'Campaign';
      case _ibb1uwag.CampaignInvitation():
        return 'CampaignInvitation';
      case _ixbyjocu.CampaignLiveUpdate():
        return 'CampaignLiveUpdate';
      case _ia1ix8k0.CampaignMapOverview():
        return 'CampaignMapOverview';
      case _iaixb6xr.CampaignMapPin():
        return 'CampaignMapPin';
      case _isbhm9y0.CampaignMatch():
        return 'CampaignMatch';
      case _i8osbdqi.CampaignParticipation():
        return 'CampaignParticipation';
      case _iz4wi5fy.CampaignPost():
        return 'CampaignPost';
      case _ibvzmbaz.CampaignProposal():
        return 'CampaignProposal';
      case _i22k3mw4.CampaignReach():
        return 'CampaignReach';
      case _iyus928a.CampaignStatus():
        return 'CampaignStatus';
      case _ixxdko7q.CampaignVolunteerMap():
        return 'CampaignVolunteerMap';
      case _ioj4s0dr.CampaignVolunteerMapMember():
        return 'CampaignVolunteerMapMember';
      case _i8shrtkg.CompletionEvidence():
        return 'CompletionEvidence';
      case _i60r3uxn.CompletionProposal():
        return 'CompletionProposal';
      case _iq1f4h1t.DashboardMetrics():
        return 'DashboardMetrics';
      case _ilzgaptr.FieldnoteException():
        return 'FieldnoteException';
      case _i1e0rn9l.ImpactSummary():
        return 'ImpactSummary';
      case _i6gdlup3.LegalConsent():
        return 'LegalConsent';
      case _i36vuf99.LegalConsentHistory():
        return 'LegalConsentHistory';
      case _ibf5kqr1.LegalPolicies():
        return 'LegalPolicies';
      case _i2sc5phg.NotificationOutbox():
        return 'NotificationOutbox';
      case _ildc7cij.ObservationCondition():
        return 'ObservationCondition';
      case _i1u7gykm.ObservationInput():
        return 'ObservationInput';
      case _i805ku85.ObservationProposal():
        return 'ObservationProposal';
      case _if13xums.Organization():
        return 'Organization';
      case _iu1h8z2d.ParticipationHistoryEntry():
        return 'ParticipationHistoryEntry';
      case _imreqlyp.ParticipationStatus():
        return 'ParticipationStatus';
      case _i6oivzdq.PaymentWebhookEvent():
        return 'PaymentWebhookEvent';
      case _i3jo3ess.PlaceSuggestion():
        return 'PlaceSuggestion';
      case _igkrjajj.RateLimitBucket():
        return 'RateLimitBucket';
      case _iuc10yd2.RazorpayCheckoutOrder():
        return 'RazorpayCheckoutOrder';
      case _il88if3j.ReachCell():
        return 'ReachCell';
      case _illv04vj.ResolvedPlace():
        return 'ResolvedPlace';
      case _iulscgnl.ReviewState():
        return 'ReviewState';
      case _i1cgh9io.Sponsorship():
        return 'Sponsorship';
      case _ihlsdeis.SponsorshipHistoryEntry():
        return 'SponsorshipHistoryEntry';
      case _ibdacauq.TestPayout():
        return 'TestPayout';
      case _iviseq0a.TestRefund():
        return 'TestRefund';
      case _it2sjc8r.TravelRoute():
        return 'TravelRoute';
      case _ik5r1rtc.TravelStep():
        return 'TravelStep';
      case _ip0a93i5.TrustCenterSummary():
        return 'TrustCenterSummary';
      case _iq3hh8xc.FieldnoteUserProfile():
        return 'FieldnoteUserProfile';
      case _ifa4ljot.VolunteerAvailability():
        return 'VolunteerAvailability';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AccountDeletionRequest') {
      return deserialize<_irc6gkwg.AccountDeletionRequest>(data['data']);
    }
    if (dataClassName == 'AccountRole') {
      return deserialize<_iwea5c8m.AccountRole>(data['data']);
    }
    if (dataClassName == 'AiConfidence') {
      return deserialize<_icuvt3ro.AiConfidence>(data['data']);
    }
    if (dataClassName == 'AuditEvent') {
      return deserialize<_i3s6sm3e.AuditEvent>(data['data']);
    }
    if (dataClassName == 'Campaign') {
      return deserialize<_imoyt016.Campaign>(data['data']);
    }
    if (dataClassName == 'CampaignInvitation') {
      return deserialize<_ibb1uwag.CampaignInvitation>(data['data']);
    }
    if (dataClassName == 'CampaignLiveUpdate') {
      return deserialize<_ixbyjocu.CampaignLiveUpdate>(data['data']);
    }
    if (dataClassName == 'CampaignMapOverview') {
      return deserialize<_ia1ix8k0.CampaignMapOverview>(data['data']);
    }
    if (dataClassName == 'CampaignMapPin') {
      return deserialize<_iaixb6xr.CampaignMapPin>(data['data']);
    }
    if (dataClassName == 'CampaignMatch') {
      return deserialize<_isbhm9y0.CampaignMatch>(data['data']);
    }
    if (dataClassName == 'CampaignParticipation') {
      return deserialize<_i8osbdqi.CampaignParticipation>(data['data']);
    }
    if (dataClassName == 'CampaignPost') {
      return deserialize<_iz4wi5fy.CampaignPost>(data['data']);
    }
    if (dataClassName == 'CampaignProposal') {
      return deserialize<_ibvzmbaz.CampaignProposal>(data['data']);
    }
    if (dataClassName == 'CampaignReach') {
      return deserialize<_i22k3mw4.CampaignReach>(data['data']);
    }
    if (dataClassName == 'CampaignStatus') {
      return deserialize<_iyus928a.CampaignStatus>(data['data']);
    }
    if (dataClassName == 'CampaignVolunteerMap') {
      return deserialize<_ixxdko7q.CampaignVolunteerMap>(data['data']);
    }
    if (dataClassName == 'CampaignVolunteerMapMember') {
      return deserialize<_ioj4s0dr.CampaignVolunteerMapMember>(data['data']);
    }
    if (dataClassName == 'CompletionEvidence') {
      return deserialize<_i8shrtkg.CompletionEvidence>(data['data']);
    }
    if (dataClassName == 'CompletionProposal') {
      return deserialize<_i60r3uxn.CompletionProposal>(data['data']);
    }
    if (dataClassName == 'DashboardMetrics') {
      return deserialize<_iq1f4h1t.DashboardMetrics>(data['data']);
    }
    if (dataClassName == 'FieldnoteException') {
      return deserialize<_ilzgaptr.FieldnoteException>(data['data']);
    }
    if (dataClassName == 'ImpactSummary') {
      return deserialize<_i1e0rn9l.ImpactSummary>(data['data']);
    }
    if (dataClassName == 'LegalConsent') {
      return deserialize<_i6gdlup3.LegalConsent>(data['data']);
    }
    if (dataClassName == 'LegalConsentHistory') {
      return deserialize<_i36vuf99.LegalConsentHistory>(data['data']);
    }
    if (dataClassName == 'LegalPolicies') {
      return deserialize<_ibf5kqr1.LegalPolicies>(data['data']);
    }
    if (dataClassName == 'NotificationOutbox') {
      return deserialize<_i2sc5phg.NotificationOutbox>(data['data']);
    }
    if (dataClassName == 'ObservationCondition') {
      return deserialize<_ildc7cij.ObservationCondition>(data['data']);
    }
    if (dataClassName == 'ObservationInput') {
      return deserialize<_i1u7gykm.ObservationInput>(data['data']);
    }
    if (dataClassName == 'ObservationProposal') {
      return deserialize<_i805ku85.ObservationProposal>(data['data']);
    }
    if (dataClassName == 'Organization') {
      return deserialize<_if13xums.Organization>(data['data']);
    }
    if (dataClassName == 'ParticipationHistoryEntry') {
      return deserialize<_iu1h8z2d.ParticipationHistoryEntry>(data['data']);
    }
    if (dataClassName == 'ParticipationStatus') {
      return deserialize<_imreqlyp.ParticipationStatus>(data['data']);
    }
    if (dataClassName == 'PaymentWebhookEvent') {
      return deserialize<_i6oivzdq.PaymentWebhookEvent>(data['data']);
    }
    if (dataClassName == 'PlaceSuggestion') {
      return deserialize<_i3jo3ess.PlaceSuggestion>(data['data']);
    }
    if (dataClassName == 'RateLimitBucket') {
      return deserialize<_igkrjajj.RateLimitBucket>(data['data']);
    }
    if (dataClassName == 'RazorpayCheckoutOrder') {
      return deserialize<_iuc10yd2.RazorpayCheckoutOrder>(data['data']);
    }
    if (dataClassName == 'ReachCell') {
      return deserialize<_il88if3j.ReachCell>(data['data']);
    }
    if (dataClassName == 'ResolvedPlace') {
      return deserialize<_illv04vj.ResolvedPlace>(data['data']);
    }
    if (dataClassName == 'ReviewState') {
      return deserialize<_iulscgnl.ReviewState>(data['data']);
    }
    if (dataClassName == 'Sponsorship') {
      return deserialize<_i1cgh9io.Sponsorship>(data['data']);
    }
    if (dataClassName == 'SponsorshipHistoryEntry') {
      return deserialize<_ihlsdeis.SponsorshipHistoryEntry>(data['data']);
    }
    if (dataClassName == 'TestPayout') {
      return deserialize<_ibdacauq.TestPayout>(data['data']);
    }
    if (dataClassName == 'TestRefund') {
      return deserialize<_iviseq0a.TestRefund>(data['data']);
    }
    if (dataClassName == 'TravelRoute') {
      return deserialize<_it2sjc8r.TravelRoute>(data['data']);
    }
    if (dataClassName == 'TravelStep') {
      return deserialize<_ik5r1rtc.TravelStep>(data['data']);
    }
    if (dataClassName == 'TrustCenterSummary') {
      return deserialize<_ip0a93i5.TrustCenterSummary>(data['data']);
    }
    if (dataClassName == 'FieldnoteUserProfile') {
      return deserialize<_iq3hh8xc.FieldnoteUserProfile>(data['data']);
    }
    if (dataClassName == 'VolunteerAvailability') {
      return deserialize<_ifa4ljot.VolunteerAvailability>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('fieldnotes', this);
    _iacs.Protocol().registerHostProtocol('fieldnotes', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _irc6gkwg.AccountDeletionRequest:
        return _irc6gkwg.AccountDeletionRequest.t;
      case _i3s6sm3e.AuditEvent:
        return _i3s6sm3e.AuditEvent.t;
      case _imoyt016.Campaign:
        return _imoyt016.Campaign.t;
      case _ibb1uwag.CampaignInvitation:
        return _ibb1uwag.CampaignInvitation.t;
      case _i8osbdqi.CampaignParticipation:
        return _i8osbdqi.CampaignParticipation.t;
      case _iz4wi5fy.CampaignPost:
        return _iz4wi5fy.CampaignPost.t;
      case _i8shrtkg.CompletionEvidence:
        return _i8shrtkg.CompletionEvidence.t;
      case _i6gdlup3.LegalConsent:
        return _i6gdlup3.LegalConsent.t;
      case _i36vuf99.LegalConsentHistory:
        return _i36vuf99.LegalConsentHistory.t;
      case _i2sc5phg.NotificationOutbox:
        return _i2sc5phg.NotificationOutbox.t;
      case _if13xums.Organization:
        return _if13xums.Organization.t;
      case _i6oivzdq.PaymentWebhookEvent:
        return _i6oivzdq.PaymentWebhookEvent.t;
      case _igkrjajj.RateLimitBucket:
        return _igkrjajj.RateLimitBucket.t;
      case _i1cgh9io.Sponsorship:
        return _i1cgh9io.Sponsorship.t;
      case _ibdacauq.TestPayout:
        return _ibdacauq.TestPayout.t;
      case _iviseq0a.TestRefund:
        return _iviseq0a.TestRefund.t;
      case _iq3hh8xc.FieldnoteUserProfile:
        return _iq3hh8xc.FieldnoteUserProfile.t;
      case _ifa4ljot.VolunteerAvailability:
        return _ifa4ljot.VolunteerAvailability.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'fieldnotes';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
