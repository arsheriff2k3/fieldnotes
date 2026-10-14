// Local sponsor UI review harness. Sample data only; never the production entrypoint.
import 'package:fieldnotes_flutter/client.dart';
import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/ui/core/fieldnote_theme.dart';
import 'package:fieldnotes_flutter/ui/core/widgets.dart';
import 'package:fieldnotes_flutter/ui/features/shell/app_shell.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/campaign_impact_report_view.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/campaign_map_view.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/campaign_post_dialog.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/campaign_readiness_view.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/campaign_volunteer_reach_view.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/manual_payout_view.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/payment_history_view.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/payout_view.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/sponsor_checkout.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/sponsor_views.dart';
import 'package:fieldnotes_flutter/ui/features/profile/profile_view.dart';
import 'package:fieldnotes_flutter/ui/features/onboarding/onboarding_view.dart';
import 'package:fieldnotes_flutter/ui/features/trust/account_data_export_view.dart';
import 'package:fieldnotes_flutter/ui/features/trust/account_deletion.dart';
import 'package:fieldnotes_flutter/ui/features/trust/trust_center_view.dart';
import 'package:fieldnotes_flutter/data/services/campaign_link_service.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/sponsor_review_fixture.dart';

class ReviewAuthStorage implements ClientAuthSuccessStorage {
  @override
  Future<AuthSuccess?> get() async => null;
  @override
  Future<void> set(AuthSuccess? value) async {}
}

void initializeReviewClient() {
  client = Client('http://127.0.0.1:1/')
    ..authSessionManager = FlutterAuthSessionManager(
      storage: ReviewAuthStorage(),
    );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeReviewClient();
  await SharedPreferences.getInstance().then(
    (p) => p.setString('fieldnote.pending-account-role', 'sponsor'),
  );
  final repo = SponsorReviewRepository();
  final model = sponsorReviewModel(repo);
  model.impacts[1] = await repo.impact(1);
  runApp(
    MaterialApp(
      theme: buildFieldnoteTheme(),
      home: Scaffold(
        appBar: AppBar(title: const Text('Sponsor UI review — sample data')),
        body: Builder(
          builder: (context) => ListView(
            children: [
              ListTile(
                title: const Text('Full sponsor navigation'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AppShell(
                      campaignLink: ValueNotifier<CampaignLinkTarget?>(null),
                      repository: repo,
                    ),
                  ),
                ),
              ),
              for (final entry in sponsorReviewScreens(repo, model).entries)
                ListTile(
                  title: Text(entry.key),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => entry.value()),
                  ),
                ),
              for (final entry in sponsorReviewModals(repo, model).entries)
                ListTile(
                  title: Text(entry.key),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => entry.value(context),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Map<String, Widget Function()> sponsorReviewScreens(
  SponsorReviewRepository repo,
  FieldnoteViewModel model,
) => {
  'discover': () => Scaffold(
    body: SafeArea(child: SponsorDiscoverView(viewModel: model)),
  ),
  'create': () => Scaffold(
    body: SafeArea(
      child: SponsorCreateView(
        viewModel: model,
        voiceController: SponsorVoiceActionController(),
      ),
    ),
  ),
  'impact': () => Scaffold(
    body: SafeArea(child: SponsorImpactView(viewModel: model)),
  ),
  'report': () => CampaignImpactReportView(campaignId: 1, repository: repo),
  'payments': () => PaymentHistoryView(viewModel: model),
  'payouts': () => CampaignPayoutView(
    campaign: reviewCampaign.copyWith(
      status: CampaignStatus.completed,
      readinessState: 'completed',
      startsAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    viewModel: model,
  ),
  'readiness': () =>
      CampaignReadinessView(campaign: reviewCampaign, viewModel: model),
  'reach': () =>
      CampaignVolunteerReachView(campaign: reviewCampaign, repository: repo),
  'trust': () => Scaffold(
    body: SafeArea(child: TrustCenterView(viewModel: model)),
  ),
  'profile': () => Scaffold(
    body: SafeArea(child: ProfileView(viewModel: model)),
  ),
  'onboarding': () => OnboardingView(viewModel: model),
  'consent': () => LegalConsentGate(viewModel: model),
  'account-export': () => AccountDataExportView(viewModel: model),
  'payout-operations': () => PayoutOperationsView(repository: repo),
  'manual-payout': () => Scaffold(
    body: SafeArea(
      child: FieldnotePageList(
        children: [ManualPayoutPanel(campaignId: 1, repository: repo)],
      ),
    ),
  ),
};

Map<String, void Function(BuildContext)> sponsorReviewModals(
  SponsorReviewRepository repo,
  FieldnoteViewModel model,
) => {
  'campaign-form': (c) => showProposalFormDialog(
    c,
    heading: 'Create campaign',
    confirmLabel: 'Use these details',
  ),
  'checkout': (c) => openSponsorCheckout(c, model, reviewCampaign),
  'campaign-post': (c) =>
      showCampaignPostDialog(c, viewModel: model, campaign: reviewCampaign),
  'discard-changes': (c) => confirmDiscard(c),
  'sign-out': (c) => confirmSignOut(c),
  'sign-out-all': (c) => confirmSignOut(c, allDevices: true),
  'delete-account': (c) => confirmAndRequestAccountDeletion(c, model),
  'evidence-sheet': (c) => showFieldnoteBottomSheet<void>(
    context: c,
    builder: (_) => EvidenceProvenanceSheet(
      evidence: reviewEvidence,
      campaign: reviewCampaign,
      reviewPanel: EvidenceReviewPanel(
        evidence: reviewEvidence,
        campaign: reviewCampaign,
        viewModel: model,
      ),
    ),
  ),
};
