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
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign.dart'
    as _i6ar8a32;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_invitation.dart'
    as _ilmm7kn9;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_match.dart'
    as _ifn539xv;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_participation.dart'
    as _i43ypuev;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/campaign_post.dart'
    as _is6qjlzb;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/place_suggestion.dart'
    as _igynj288;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/sponsorship.dart'
    as _iffokzpe;
import 'package:fieldnotes_client/src/protocol/fieldnotes/models/test_payout.dart'
    as _irfbdx5f;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'fieldnotes/models/account_role.dart' as _iwea5c8m;
import 'fieldnotes/models/ai_confidence.dart' as _icuvt3ro;
import 'fieldnotes/models/asset.dart' as _iyem7tcm;
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
import 'fieldnotes/models/completion_evidence.dart' as _i8shrtkg;
import 'fieldnotes/models/completion_proposal.dart' as _i60r3uxn;
import 'fieldnotes/models/dashboard_metrics.dart' as _iq1f4h1t;
import 'fieldnotes/models/fieldnote_exception.dart' as _ilzgaptr;
import 'fieldnotes/models/follow_up_task.dart' as _if81yiw4;
import 'fieldnotes/models/impact_summary.dart' as _i1e0rn9l;
import 'fieldnotes/models/legal_consent.dart' as _i6gdlup3;
import 'fieldnotes/models/member_role.dart' as _ihhblray;
import 'fieldnotes/models/observation.dart' as _iw544tuw;
import 'fieldnotes/models/observation_condition.dart' as _ildc7cij;
import 'fieldnotes/models/observation_input.dart' as _i1u7gykm;
import 'fieldnotes/models/observation_media.dart' as _iv2wmuo1;
import 'fieldnotes/models/observation_proposal.dart' as _i805ku85;
import 'fieldnotes/models/organization.dart' as _if13xums;
import 'fieldnotes/models/organization_member.dart' as _ifgsfd6p;
import 'fieldnotes/models/participation_status.dart' as _imreqlyp;
import 'fieldnotes/models/place_suggestion.dart' as _i3jo3ess;
import 'fieldnotes/models/razorpay_checkout_order.dart' as _iuc10yd2;
import 'fieldnotes/models/reach_cell.dart' as _il88if3j;
import 'fieldnotes/models/resolved_place.dart' as _illv04vj;
import 'fieldnotes/models/review_decision.dart' as _iotfc67y;
import 'fieldnotes/models/review_outcome.dart' as _imia3a4e;
import 'fieldnotes/models/review_state.dart' as _iulscgnl;
import 'fieldnotes/models/sponsorship.dart' as _i1cgh9io;
import 'fieldnotes/models/task_status.dart' as _ixrvqme0;
import 'fieldnotes/models/test_payout.dart' as _ibdacauq;
import 'fieldnotes/models/test_refund.dart' as _iviseq0a;
import 'fieldnotes/models/travel_route.dart' as _it2sjc8r;
import 'fieldnotes/models/travel_step.dart' as _ik5r1rtc;
import 'fieldnotes/models/trust_center_summary.dart' as _ip0a93i5;
import 'fieldnotes/models/user_profile.dart' as _iq3hh8xc;
import 'fieldnotes/models/volunteer_availability.dart' as _ifa4ljot;
import 'fieldnotes/models/workspace_summary.dart' as _im8apr1y;
import 'greetings/greeting.dart' as _izw8z7ou;
export 'fieldnotes/models/account_role.dart';
export 'fieldnotes/models/ai_confidence.dart';
export 'fieldnotes/models/asset.dart';
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
export 'fieldnotes/models/completion_evidence.dart';
export 'fieldnotes/models/completion_proposal.dart';
export 'fieldnotes/models/dashboard_metrics.dart';
export 'fieldnotes/models/fieldnote_exception.dart';
export 'fieldnotes/models/follow_up_task.dart';
export 'fieldnotes/models/impact_summary.dart';
export 'fieldnotes/models/legal_consent.dart';
export 'fieldnotes/models/member_role.dart';
export 'fieldnotes/models/observation.dart';
export 'fieldnotes/models/observation_condition.dart';
export 'fieldnotes/models/observation_input.dart';
export 'fieldnotes/models/observation_media.dart';
export 'fieldnotes/models/observation_proposal.dart';
export 'fieldnotes/models/organization.dart';
export 'fieldnotes/models/organization_member.dart';
export 'fieldnotes/models/participation_status.dart';
export 'fieldnotes/models/place_suggestion.dart';
export 'fieldnotes/models/razorpay_checkout_order.dart';
export 'fieldnotes/models/reach_cell.dart';
export 'fieldnotes/models/resolved_place.dart';
export 'fieldnotes/models/review_decision.dart';
export 'fieldnotes/models/review_outcome.dart';
export 'fieldnotes/models/review_state.dart';
export 'fieldnotes/models/sponsorship.dart';
export 'fieldnotes/models/task_status.dart';
export 'fieldnotes/models/test_payout.dart';
export 'fieldnotes/models/test_refund.dart';
export 'fieldnotes/models/travel_route.dart';
export 'fieldnotes/models/travel_step.dart';
export 'fieldnotes/models/trust_center_summary.dart';
export 'fieldnotes/models/user_profile.dart';
export 'fieldnotes/models/volunteer_availability.dart';
export 'fieldnotes/models/workspace_summary.dart';
export 'greetings/greeting.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

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
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iwea5c8m.AccountRole) {
      return _iwea5c8m.AccountRole.fromJson(data) as T;
    }
    if (t == _icuvt3ro.AiConfidence) {
      return _icuvt3ro.AiConfidence.fromJson(data) as T;
    }
    if (t == _iyem7tcm.Asset) {
      return _iyem7tcm.Asset.fromJson(data) as T;
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
    if (t == _if81yiw4.FollowUpTask) {
      return _if81yiw4.FollowUpTask.fromJson(data) as T;
    }
    if (t == _i1e0rn9l.ImpactSummary) {
      return _i1e0rn9l.ImpactSummary.fromJson(data) as T;
    }
    if (t == _i6gdlup3.LegalConsent) {
      return _i6gdlup3.LegalConsent.fromJson(data) as T;
    }
    if (t == _ihhblray.MemberRole) {
      return _ihhblray.MemberRole.fromJson(data) as T;
    }
    if (t == _iw544tuw.Observation) {
      return _iw544tuw.Observation.fromJson(data) as T;
    }
    if (t == _ildc7cij.ObservationCondition) {
      return _ildc7cij.ObservationCondition.fromJson(data) as T;
    }
    if (t == _i1u7gykm.ObservationInput) {
      return _i1u7gykm.ObservationInput.fromJson(data) as T;
    }
    if (t == _iv2wmuo1.ObservationMedia) {
      return _iv2wmuo1.ObservationMedia.fromJson(data) as T;
    }
    if (t == _i805ku85.ObservationProposal) {
      return _i805ku85.ObservationProposal.fromJson(data) as T;
    }
    if (t == _if13xums.Organization) {
      return _if13xums.Organization.fromJson(data) as T;
    }
    if (t == _ifgsfd6p.OrganizationMember) {
      return _ifgsfd6p.OrganizationMember.fromJson(data) as T;
    }
    if (t == _imreqlyp.ParticipationStatus) {
      return _imreqlyp.ParticipationStatus.fromJson(data) as T;
    }
    if (t == _i3jo3ess.PlaceSuggestion) {
      return _i3jo3ess.PlaceSuggestion.fromJson(data) as T;
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
    if (t == _iotfc67y.ReviewDecision) {
      return _iotfc67y.ReviewDecision.fromJson(data) as T;
    }
    if (t == _imia3a4e.ReviewOutcome) {
      return _imia3a4e.ReviewOutcome.fromJson(data) as T;
    }
    if (t == _iulscgnl.ReviewState) {
      return _iulscgnl.ReviewState.fromJson(data) as T;
    }
    if (t == _i1cgh9io.Sponsorship) {
      return _i1cgh9io.Sponsorship.fromJson(data) as T;
    }
    if (t == _ixrvqme0.TaskStatus) {
      return _ixrvqme0.TaskStatus.fromJson(data) as T;
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
    if (t == _im8apr1y.WorkspaceSummary) {
      return _im8apr1y.WorkspaceSummary.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _isc.getType<_iwea5c8m.AccountRole?>()) {
      return (data != null ? _iwea5c8m.AccountRole.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_icuvt3ro.AiConfidence?>()) {
      return (data != null ? _icuvt3ro.AiConfidence.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iyem7tcm.Asset?>()) {
      return (data != null ? _iyem7tcm.Asset.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i3s6sm3e.AuditEvent?>()) {
      return (data != null ? _i3s6sm3e.AuditEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_imoyt016.Campaign?>()) {
      return (data != null ? _imoyt016.Campaign.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ibb1uwag.CampaignInvitation?>()) {
      return (data != null ? _ibb1uwag.CampaignInvitation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixbyjocu.CampaignLiveUpdate?>()) {
      return (data != null ? _ixbyjocu.CampaignLiveUpdate.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ia1ix8k0.CampaignMapOverview?>()) {
      return (data != null
              ? _ia1ix8k0.CampaignMapOverview.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iaixb6xr.CampaignMapPin?>()) {
      return (data != null ? _iaixb6xr.CampaignMapPin.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_isbhm9y0.CampaignMatch?>()) {
      return (data != null ? _isbhm9y0.CampaignMatch.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i8osbdqi.CampaignParticipation?>()) {
      return (data != null
              ? _i8osbdqi.CampaignParticipation.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iz4wi5fy.CampaignPost?>()) {
      return (data != null ? _iz4wi5fy.CampaignPost.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ibvzmbaz.CampaignProposal?>()) {
      return (data != null ? _ibvzmbaz.CampaignProposal.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i22k3mw4.CampaignReach?>()) {
      return (data != null ? _i22k3mw4.CampaignReach.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iyus928a.CampaignStatus?>()) {
      return (data != null ? _iyus928a.CampaignStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i8shrtkg.CompletionEvidence?>()) {
      return (data != null ? _i8shrtkg.CompletionEvidence.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i60r3uxn.CompletionProposal?>()) {
      return (data != null ? _i60r3uxn.CompletionProposal.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iq1f4h1t.DashboardMetrics?>()) {
      return (data != null ? _iq1f4h1t.DashboardMetrics.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ilzgaptr.FieldnoteException?>()) {
      return (data != null ? _ilzgaptr.FieldnoteException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_if81yiw4.FollowUpTask?>()) {
      return (data != null ? _if81yiw4.FollowUpTask.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i1e0rn9l.ImpactSummary?>()) {
      return (data != null ? _i1e0rn9l.ImpactSummary.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i6gdlup3.LegalConsent?>()) {
      return (data != null ? _i6gdlup3.LegalConsent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ihhblray.MemberRole?>()) {
      return (data != null ? _ihhblray.MemberRole.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iw544tuw.Observation?>()) {
      return (data != null ? _iw544tuw.Observation.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ildc7cij.ObservationCondition?>()) {
      return (data != null
              ? _ildc7cij.ObservationCondition.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i1u7gykm.ObservationInput?>()) {
      return (data != null ? _i1u7gykm.ObservationInput.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iv2wmuo1.ObservationMedia?>()) {
      return (data != null ? _iv2wmuo1.ObservationMedia.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i805ku85.ObservationProposal?>()) {
      return (data != null
              ? _i805ku85.ObservationProposal.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_if13xums.Organization?>()) {
      return (data != null ? _if13xums.Organization.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ifgsfd6p.OrganizationMember?>()) {
      return (data != null ? _ifgsfd6p.OrganizationMember.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_imreqlyp.ParticipationStatus?>()) {
      return (data != null
              ? _imreqlyp.ParticipationStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i3jo3ess.PlaceSuggestion?>()) {
      return (data != null ? _i3jo3ess.PlaceSuggestion.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iuc10yd2.RazorpayCheckoutOrder?>()) {
      return (data != null
              ? _iuc10yd2.RazorpayCheckoutOrder.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_il88if3j.ReachCell?>()) {
      return (data != null ? _il88if3j.ReachCell.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_illv04vj.ResolvedPlace?>()) {
      return (data != null ? _illv04vj.ResolvedPlace.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iotfc67y.ReviewDecision?>()) {
      return (data != null ? _iotfc67y.ReviewDecision.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_imia3a4e.ReviewOutcome?>()) {
      return (data != null ? _imia3a4e.ReviewOutcome.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iulscgnl.ReviewState?>()) {
      return (data != null ? _iulscgnl.ReviewState.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i1cgh9io.Sponsorship?>()) {
      return (data != null ? _i1cgh9io.Sponsorship.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixrvqme0.TaskStatus?>()) {
      return (data != null ? _ixrvqme0.TaskStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ibdacauq.TestPayout?>()) {
      return (data != null ? _ibdacauq.TestPayout.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iviseq0a.TestRefund?>()) {
      return (data != null ? _iviseq0a.TestRefund.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_it2sjc8r.TravelRoute?>()) {
      return (data != null ? _it2sjc8r.TravelRoute.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ik5r1rtc.TravelStep?>()) {
      return (data != null ? _ik5r1rtc.TravelStep.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ip0a93i5.TrustCenterSummary?>()) {
      return (data != null ? _ip0a93i5.TrustCenterSummary.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iq3hh8xc.FieldnoteUserProfile?>()) {
      return (data != null
              ? _iq3hh8xc.FieldnoteUserProfile.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ifa4ljot.VolunteerAvailability?>()) {
      return (data != null
              ? _ifa4ljot.VolunteerAvailability.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_im8apr1y.WorkspaceSummary?>()) {
      return (data != null ? _im8apr1y.WorkspaceSummary.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
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
    if (t == List<_imoyt016.Campaign>) {
      return (data as List)
              .map((e) => deserialize<_imoyt016.Campaign>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_i6ar8a32.Campaign>) {
      return (data as List)
              .map((e) => deserialize<_i6ar8a32.Campaign>(e))
              .toList()
          as T;
    }
    if (t == List<_igynj288.PlaceSuggestion>) {
      return (data as List)
              .map((e) => deserialize<_igynj288.PlaceSuggestion>(e))
              .toList()
          as T;
    }
    if (t == List<_ilmm7kn9.CampaignInvitation>) {
      return (data as List)
              .map((e) => deserialize<_ilmm7kn9.CampaignInvitation>(e))
              .toList()
          as T;
    }
    if (t == List<_iffokzpe.Sponsorship>) {
      return (data as List)
              .map((e) => deserialize<_iffokzpe.Sponsorship>(e))
              .toList()
          as T;
    }
    if (t == List<_irfbdx5f.TestPayout>) {
      return (data as List)
              .map((e) => deserialize<_irfbdx5f.TestPayout>(e))
              .toList()
          as T;
    }
    if (t == List<_ifn539xv.CampaignMatch>) {
      return (data as List)
              .map((e) => deserialize<_ifn539xv.CampaignMatch>(e))
              .toList()
          as T;
    }
    if (t == List<_i43ypuev.CampaignParticipation>) {
      return (data as List)
              .map((e) => deserialize<_i43ypuev.CampaignParticipation>(e))
              .toList()
          as T;
    }
    if (t == List<_is6qjlzb.CampaignPost>) {
      return (data as List)
              .map((e) => deserialize<_is6qjlzb.CampaignPost>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iwea5c8m.AccountRole => 'AccountRole',
      _icuvt3ro.AiConfidence => 'AiConfidence',
      _iyem7tcm.Asset => 'Asset',
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
      _i8shrtkg.CompletionEvidence => 'CompletionEvidence',
      _i60r3uxn.CompletionProposal => 'CompletionProposal',
      _iq1f4h1t.DashboardMetrics => 'DashboardMetrics',
      _ilzgaptr.FieldnoteException => 'FieldnoteException',
      _if81yiw4.FollowUpTask => 'FollowUpTask',
      _i1e0rn9l.ImpactSummary => 'ImpactSummary',
      _i6gdlup3.LegalConsent => 'LegalConsent',
      _ihhblray.MemberRole => 'MemberRole',
      _iw544tuw.Observation => 'Observation',
      _ildc7cij.ObservationCondition => 'ObservationCondition',
      _i1u7gykm.ObservationInput => 'ObservationInput',
      _iv2wmuo1.ObservationMedia => 'ObservationMedia',
      _i805ku85.ObservationProposal => 'ObservationProposal',
      _if13xums.Organization => 'Organization',
      _ifgsfd6p.OrganizationMember => 'OrganizationMember',
      _imreqlyp.ParticipationStatus => 'ParticipationStatus',
      _i3jo3ess.PlaceSuggestion => 'PlaceSuggestion',
      _iuc10yd2.RazorpayCheckoutOrder => 'RazorpayCheckoutOrder',
      _il88if3j.ReachCell => 'ReachCell',
      _illv04vj.ResolvedPlace => 'ResolvedPlace',
      _iotfc67y.ReviewDecision => 'ReviewDecision',
      _imia3a4e.ReviewOutcome => 'ReviewOutcome',
      _iulscgnl.ReviewState => 'ReviewState',
      _i1cgh9io.Sponsorship => 'Sponsorship',
      _ixrvqme0.TaskStatus => 'TaskStatus',
      _ibdacauq.TestPayout => 'TestPayout',
      _iviseq0a.TestRefund => 'TestRefund',
      _it2sjc8r.TravelRoute => 'TravelRoute',
      _ik5r1rtc.TravelStep => 'TravelStep',
      _ip0a93i5.TrustCenterSummary => 'TrustCenterSummary',
      _iq3hh8xc.FieldnoteUserProfile => 'FieldnoteUserProfile',
      _ifa4ljot.VolunteerAvailability => 'VolunteerAvailability',
      _im8apr1y.WorkspaceSummary => 'WorkspaceSummary',
      _izw8z7ou.Greeting => 'Greeting',
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
      case _iwea5c8m.AccountRole():
        return 'AccountRole';
      case _icuvt3ro.AiConfidence():
        return 'AiConfidence';
      case _iyem7tcm.Asset():
        return 'Asset';
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
      case _i8shrtkg.CompletionEvidence():
        return 'CompletionEvidence';
      case _i60r3uxn.CompletionProposal():
        return 'CompletionProposal';
      case _iq1f4h1t.DashboardMetrics():
        return 'DashboardMetrics';
      case _ilzgaptr.FieldnoteException():
        return 'FieldnoteException';
      case _if81yiw4.FollowUpTask():
        return 'FollowUpTask';
      case _i1e0rn9l.ImpactSummary():
        return 'ImpactSummary';
      case _i6gdlup3.LegalConsent():
        return 'LegalConsent';
      case _ihhblray.MemberRole():
        return 'MemberRole';
      case _iw544tuw.Observation():
        return 'Observation';
      case _ildc7cij.ObservationCondition():
        return 'ObservationCondition';
      case _i1u7gykm.ObservationInput():
        return 'ObservationInput';
      case _iv2wmuo1.ObservationMedia():
        return 'ObservationMedia';
      case _i805ku85.ObservationProposal():
        return 'ObservationProposal';
      case _if13xums.Organization():
        return 'Organization';
      case _ifgsfd6p.OrganizationMember():
        return 'OrganizationMember';
      case _imreqlyp.ParticipationStatus():
        return 'ParticipationStatus';
      case _i3jo3ess.PlaceSuggestion():
        return 'PlaceSuggestion';
      case _iuc10yd2.RazorpayCheckoutOrder():
        return 'RazorpayCheckoutOrder';
      case _il88if3j.ReachCell():
        return 'ReachCell';
      case _illv04vj.ResolvedPlace():
        return 'ResolvedPlace';
      case _iotfc67y.ReviewDecision():
        return 'ReviewDecision';
      case _imia3a4e.ReviewOutcome():
        return 'ReviewOutcome';
      case _iulscgnl.ReviewState():
        return 'ReviewState';
      case _i1cgh9io.Sponsorship():
        return 'Sponsorship';
      case _ixrvqme0.TaskStatus():
        return 'TaskStatus';
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
      case _im8apr1y.WorkspaceSummary():
        return 'WorkspaceSummary';
      case _izw8z7ou.Greeting():
        return 'Greeting';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AccountRole') {
      return deserialize<_iwea5c8m.AccountRole>(data['data']);
    }
    if (dataClassName == 'AiConfidence') {
      return deserialize<_icuvt3ro.AiConfidence>(data['data']);
    }
    if (dataClassName == 'Asset') {
      return deserialize<_iyem7tcm.Asset>(data['data']);
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
    if (dataClassName == 'FollowUpTask') {
      return deserialize<_if81yiw4.FollowUpTask>(data['data']);
    }
    if (dataClassName == 'ImpactSummary') {
      return deserialize<_i1e0rn9l.ImpactSummary>(data['data']);
    }
    if (dataClassName == 'LegalConsent') {
      return deserialize<_i6gdlup3.LegalConsent>(data['data']);
    }
    if (dataClassName == 'MemberRole') {
      return deserialize<_ihhblray.MemberRole>(data['data']);
    }
    if (dataClassName == 'Observation') {
      return deserialize<_iw544tuw.Observation>(data['data']);
    }
    if (dataClassName == 'ObservationCondition') {
      return deserialize<_ildc7cij.ObservationCondition>(data['data']);
    }
    if (dataClassName == 'ObservationInput') {
      return deserialize<_i1u7gykm.ObservationInput>(data['data']);
    }
    if (dataClassName == 'ObservationMedia') {
      return deserialize<_iv2wmuo1.ObservationMedia>(data['data']);
    }
    if (dataClassName == 'ObservationProposal') {
      return deserialize<_i805ku85.ObservationProposal>(data['data']);
    }
    if (dataClassName == 'Organization') {
      return deserialize<_if13xums.Organization>(data['data']);
    }
    if (dataClassName == 'OrganizationMember') {
      return deserialize<_ifgsfd6p.OrganizationMember>(data['data']);
    }
    if (dataClassName == 'ParticipationStatus') {
      return deserialize<_imreqlyp.ParticipationStatus>(data['data']);
    }
    if (dataClassName == 'PlaceSuggestion') {
      return deserialize<_i3jo3ess.PlaceSuggestion>(data['data']);
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
    if (dataClassName == 'ReviewDecision') {
      return deserialize<_iotfc67y.ReviewDecision>(data['data']);
    }
    if (dataClassName == 'ReviewOutcome') {
      return deserialize<_imia3a4e.ReviewOutcome>(data['data']);
    }
    if (dataClassName == 'ReviewState') {
      return deserialize<_iulscgnl.ReviewState>(data['data']);
    }
    if (dataClassName == 'Sponsorship') {
      return deserialize<_i1cgh9io.Sponsorship>(data['data']);
    }
    if (dataClassName == 'TaskStatus') {
      return deserialize<_ixrvqme0.TaskStatus>(data['data']);
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
    if (dataClassName == 'WorkspaceSummary') {
      return deserialize<_im8apr1y.WorkspaceSummary>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('fieldnotes', this);
    _iacc.Protocol().registerHostProtocol('fieldnotes', this);
  }

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
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
