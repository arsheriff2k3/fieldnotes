import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/legal.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'account_data_export_view.dart';
import 'account_deletion.dart';

/// Shown when the account has no current consent: first sign-in after a
/// policy change, or after the user withdrew consent.
class LegalConsentGate extends StatefulWidget {
  const LegalConsentGate({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  State<LegalConsentGate> createState() => _LegalConsentGateState();
}

class _LegalConsentGateState extends State<LegalConsentGate> {
  final Map<String, bool> _values = {};
  bool _saving = false;

  FieldnoteViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    if (_viewModel.legalPolicies == null) _viewModel.loadLegalPolicies();
  }

  bool get _canAccept =>
      !_saving && requiredConsentsGiven(_values, _viewModel.legalPolicies);

  Future<void> _accept() async {
    if (!_canAccept) return;
    setState(() => _saving = true);
    try {
      await _viewModel.acceptLegalConsent(
        locationConsent: _values[consentLocation] ?? false,
        aiProcessingConsent: _values[consentAiProcessing] ?? false,
        evidenceSharingConsent: _values[consentEvidenceSharing] ?? false,
      );
    } on Object catch (error) {
      if (error is FieldnoteException &&
          error.code == 'consent_version_mismatch') {
        await _viewModel.loadLegalPolicies();
        await _viewModel.refresh();
      }
      if (mounted) {
        showFieldnoteNotice(
          context,
          title: 'Consent not saved',
          message: userMessageFor(
            error,
            fallback: 'Could not save your consent. Try again.',
          ),
          kind: FieldnoteNoticeKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await confirmSignOut(context);
    if (confirmed == true) await _viewModel.signOut();
  }

  String _description() {
    final consent = _viewModel.consent;
    if (consent == null) {
      return 'FieldNote uses location, AI, and private evidence to connect '
          'sponsorship with verified volunteer work.';
    }
    final trust = _viewModel.trustCenter;
    if (trust != null &&
        (consent.privacyPolicyVersion != trust.privacyPolicyVersion ||
            consent.termsVersion != trust.termsVersion)) {
      return 'The Privacy Policy or Terms changed since you last agreed. '
          'Review them and confirm your choices to continue.';
    }
    return 'You withdrew consent, so matching, check-in, AI drafts and '
        'evidence sharing are paused. Accept again to keep using FieldNote, '
        'or delete your account.';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final policies = _viewModel.legalPolicies;
        final privacyVersion =
            policies?.privacyPolicyVersion ??
            _viewModel.trustCenter?.privacyPolicyVersion;
        final termsVersion =
            policies?.termsVersion ?? _viewModel.trustCenter?.termsVersion;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: FieldnotePageList(
                  top: FieldnoteSpacing.xl,
                  bottom: FieldnoteSpacing.xl,
                  maxWidth: 720,
                  shrinkWrap: true,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 52,
                      color: FieldnoteColors.forest,
                    ),
                    const SizedBox(height: 16),
                    SectionHeading(
                      eyebrow: 'Trust before action',
                      title: 'Review your privacy choices',
                      description: _description(),
                    ),
                    const SizedBox(height: 18),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConsentChecklist(
                            values: _values,
                            policies: policies,
                            enabled: !_saving,
                            onChanged: (key, value) =>
                                setState(() => _values[key] = value),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                            child: Text(
                              privacyVersion == null || termsVersion == null
                                  ? 'By continuing you accept the current '
                                        'FieldNote Terms and Privacy Policy.'
                                  : 'By continuing you accept the FieldNote '
                                        'Terms v$termsVersion and Privacy '
                                        'Policy v$privacyVersion.',
                            ),
                          ),
                          LegalLinks(
                            policies: policies,
                            onRetry: _viewModel.loadLegalPolicies,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              key: const ValueKey('accept-consent'),
                              onPressed: _canAccept ? _accept : null,
                              icon: const Icon(Icons.shield_outlined),
                              label: Text(
                                _saving ? 'Saving…' : 'Accept and continue',
                              ),
                            ),
                          ),
                          if (!requiredConsentsGiven(_values, policies)) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Check every required choice to continue.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _saving ? null : _signOut,
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign out'),
                        ),
                        TextButton.icon(
                          onPressed: _saving
                              ? null
                              : () => confirmAndRequestAccountDeletion(
                                  context,
                                  _viewModel,
                                ),
                          style: TextButton.styleFrom(
                            foregroundColor: FieldnoteColors.danger,
                          ),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete my account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Confirms signing out of this device.
Future<bool?> confirmSignOut(BuildContext context, {bool allDevices = false}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(allDevices ? 'Sign out of all devices?' : 'Sign out?'),
      content: Text(
        allDevices
            ? 'Every device signed in to this account, including this one, '
                  'will need to sign in again.'
            : 'You will need to sign in again to use FieldNote on this '
                  'device.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(allDevices ? 'Sign out everywhere' : 'Sign out'),
        ),
      ],
    ),
  );
}

class TrustCenterView extends StatefulWidget {
  const TrustCenterView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  State<TrustCenterView> createState() => _TrustCenterViewState();
}

final _activityTime = DateFormat('d MMM yyyy, HH:mm');

/// True when [consent] grants every consent for the current versions.
bool consentIsCurrent(LegalConsent? consent, TrustCenterSummary? trust) =>
    consent != null &&
    consent.locationConsent &&
    consent.aiProcessingConsent &&
    consent.evidenceSharingConsent &&
    (trust == null ||
        (consent.privacyPolicyVersion == trust.privacyPolicyVersion &&
            consent.termsVersion == trust.termsVersion));

class _TrustCenterViewState extends State<TrustCenterView> {
  FieldnoteViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.loadConsentHistory();
    if (viewModel.legalPolicies == null) viewModel.loadLegalPolicies();
  }

  Future<void> _refresh() async {
    await viewModel.refresh();
    await Future.wait([
      viewModel.loadConsentHistory(),
      viewModel.refreshDeletionStatus(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final trust = viewModel.trustCenter;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FieldnotePageList(
        children: [
          const SectionHeading(
            eyebrow: 'Your account',
            title: 'Trust & safety',
            description: 'Review privacy controls and account activity.',
          ),
          const SizedBox(height: 16),
          if (trust == null)
            const EmptyPanel(
              icon: Icons.shield_outlined,
              title: 'Trust data is loading',
              message:
                  'Pull to refresh the security activity for this account.',
            )
          else ...[
            ResponsiveCardGrid(
              minimumItemWidth: 300,
              spacing: 14,
              children: [
                _ProtectionCard(
                  icon: Icons.payments_outlined,
                  title: 'Verified payments',
                  detail: trust.paymentProtection,
                ),
                _ProtectionCard(
                  icon: Icons.gps_fixed,
                  title: 'Location integrity',
                  detail: trust.locationProtection,
                ),
                _ProtectionCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Content moderation',
                  detail: trust.moderationProtection,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _privacyControls(context, trust),
            const SizedBox(height: 18),
            _consentHistory(context),
            const SizedBox(height: 18),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  if (trust.recentEvents.isEmpty)
                    const Text('No security events recorded yet.')
                  else ...[
                    for (final event in trust.recentEvents.take(3))
                      _activityTile(context, event),
                    if (trust.recentEvents.length > 3) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _showActivity(
                            context,
                            trust.recentEvents,
                          ),
                          icon: const Icon(Icons.history),
                          label: Text(
                            'View all ${trust.recentEvents.length} events',
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            AccountDeletionCard(viewModel: viewModel),
          ],
        ],
      ),
    );
  }

  Widget _privacyControls(BuildContext context, TrustCenterSummary trust) {
    final consent = viewModel.consent;
    final current = consentIsCurrent(consent, trust);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.privacy_tip_outlined,
                color: FieldnoteColors.forest,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Privacy controls',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatusPill(
            label: current
                ? 'Consent recorded'
                : consent == null
                ? 'No consent recorded'
                : 'Consent withdrawn or out of date',
            color: current ? FieldnoteColors.forest : FieldnoteColors.clay,
            icon: current ? Icons.check_circle_outline : Icons.error_outline,
          ),
          if (consent != null) ...[
            const SizedBox(height: 6),
            Text(
              current
                  ? 'Accepted ${_activityTime.format(consent.acceptedAt.toLocal())} '
                        '(Privacy Policy v${consent.privacyPolicyVersion}, '
                        'Terms v${consent.termsVersion}).'
                  : 'Last updated ${_activityTime.format(consent.updatedAt.toLocal())}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Text(trust.retentionNotice),
          const SizedBox(height: 6),
          Text(
            'Current Privacy Policy v${trust.privacyPolicyVersion} · '
            'Terms v${trust.termsVersion}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          LegalLinks(
            policies: viewModel.legalPolicies,
            onRetry: viewModel.loadLegalPolicies,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _export(context),
                icon: const Icon(Icons.download_outlined),
                label: const Text('View and export my data'),
              ),
              if (current)
                OutlinedButton.icon(
                  onPressed: () => _withdraw(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FieldnoteColors.danger,
                  ),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Withdraw consent'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _consentHistory(BuildContext context) {
    final history = viewModel.consentHistory;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consent history',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          if (history.isEmpty)
            const Text('No consent changes recorded yet.')
          else
            for (final entry in history.take(10)) _consentTile(context, entry),
        ],
      ),
    );
  }

  Widget _consentTile(BuildContext context, LegalConsentHistory entry) {
    final withdrawn = entry.action == 'withdrawn';
    final granted = [
      if (entry.locationConsent) 'GPS',
      if (entry.aiProcessingConsent) 'AI',
      if (entry.evidenceSharingConsent) 'evidence sharing',
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        withdrawn ? Icons.remove_circle_outline : Icons.check_circle_outline,
        color: withdrawn ? FieldnoteColors.clay : FieldnoteColors.forest,
      ),
      title: Text(withdrawn ? 'Consent withdrawn' : 'Consent accepted'),
      subtitle: Text(
        '${_activityTime.format(entry.recordedAt.toLocal())} · '
        'Privacy v${entry.privacyPolicyVersion}, Terms v${entry.termsVersion}'
        '${granted.isEmpty ? '' : ' · ${granted.join(', ')}'}',
      ),
    );
  }

  Future<void> _withdraw(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw consent?'),
        content: const Text(
          'FieldNote needs GPS, AI processing and private evidence sharing to '
          'work. After you withdraw, matching, check-in, AI drafts and '
          'evidence submission stop, and you will be asked to accept again '
          'before you can use the app. Your existing records stay until you '
          'delete your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep consent'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: FieldnoteColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await viewModel.withdrawConsent();
    } on Object catch (error) {
      if (context.mounted) {
        showFieldnoteNotice(
          context,
          title: 'Consent not withdrawn',
          message: userMessageFor(error),
          kind: FieldnoteNoticeKind.error,
        );
      }
    }
  }

  Widget _activityTile(
    BuildContext context,
    AuditEvent event, {
    bool compact = true,
  }) {
    final rejected = event.outcome == 'rejected';
    final detail = event.detail.trim();
    final shownDetail = detail.isEmpty || detail.toLowerCase() == 'undefined'
        ? event.event == 'paymentCheckoutFailed'
              ? 'Checkout did not complete.'
              : ''
        : detail;
    final time = _activityTime.format(event.occurredAt.toLocal());
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        rejected ? Icons.gpp_bad_outlined : Icons.verified_user_outlined,
        color: rejected ? FieldnoteColors.clay : FieldnoteColors.forest,
      ),
      title: Text(_eventTitle(event.event)),
      subtitle: Text(
        shownDetail.isEmpty ? time : '$time · $shownDetail',
        maxLines: compact ? 2 : null,
        overflow: compact ? TextOverflow.ellipsis : null,
      ),
    );
  }

  void _showActivity(BuildContext context, List<AuditEvent> events) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .78,
        minChildSize: .45,
        maxChildSize: .95,
        builder: (context, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Security activity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text('${events.length} events'),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: events.length,
                itemBuilder: (context, index) => _activityTile(
                  context,
                  events[index],
                  compact: false,
                ),
                separatorBuilder: (_, _) => const Divider(height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountDataExportView(viewModel: viewModel),
      ),
    );
    if (context.mounted) await viewModel.refresh();
  }

  static String _eventTitle(String value) => switch (value) {
    'paymentOrderCreated' => 'Razorpay order created',
    'paymentSignatureVerified' => 'Payment signature checked',
    'paymentCheckoutFailed' => 'Checkout failed or cancelled',
    'paymentVerifiedWithoutCredit' => 'Payment verification reviewed',
    'paymentOrderCreate' => 'Checkout requested',
    'locationCheckIn' => 'Check-in integrity checked',
    'evidenceLocationIntegrity' => 'Evidence location checked',
    'evidenceSubmitted' => 'Evidence verified',
    'contentModeration' => 'Content moderation decision',
    'legalConsentAccepted' => 'Consent accepted',
    'legalConsentWithdrawn' => 'Consent withdrawn',
    'privacyDataExported' => 'Data exported',
    'testPayoutSimulated' || 'testPayoutsSimulated' => 'Test payout recorded',
    'accountDeletionRequested' => 'Deletion requested',
    _ => value,
  };
}

class _ProtectionCard extends StatelessWidget {
  const _ProtectionCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: FieldnoteColors.forest, size: 23),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
