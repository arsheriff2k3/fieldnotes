import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/legal.dart';
import '../../core/widgets.dart';
import '../../../l10n/l10n.dart';
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
    final l10n = context.l10n;
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
          title: l10n.consentNotSavedTitle,
          message: userMessageFor(
            error,
            fallback: l10n.consentNotSavedBody,
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
    final l10n = context.l10n;
    final consent = _viewModel.consent;
    if (consent == null) return l10n.consentGateIntro;
    final trust = _viewModel.trustCenter;
    if (trust != null &&
        (consent.privacyPolicyVersion != trust.privacyPolicyVersion ||
            consent.termsVersion != trust.termsVersion)) {
      return l10n.consentGatePolicyChanged;
    }
    return l10n.consentGateWithdrawn;
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
        final l10n = context.l10n;
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
                    Icon(
                      Icons.verified_user_outlined,
                      size: 52,
                      color: context.fieldnoteColors.forest,
                    ),
                    const SizedBox(height: FieldnoteSpacing.md),
                    SectionHeading(
                      eyebrow: l10n.consentGateEyebrow,
                      title: l10n.consentGateTitle,
                      description: _description(),
                    ),
                    const SizedBox(height: FieldnoteSpacing.md),
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
                                  ? l10n.onboardingAcceptCurrent
                                  : l10n.onboardingAcceptVersions(
                                      termsVersion,
                                      privacyVersion,
                                    ),
                            ),
                          ),
                          LegalLinks(
                            policies: policies,
                            onRetry: _viewModel.loadLegalPolicies,
                          ),
                          const SizedBox(height: FieldnoteSpacing.xs),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              key: const ValueKey('accept-consent'),
                              onPressed: _canAccept ? _accept : null,
                              icon: const Icon(Icons.shield_outlined),
                              label: Text(
                                _saving
                                    ? l10n.commonSaving
                                    : l10n.consentAcceptAndContinue,
                              ),
                            ),
                          ),
                          if (!requiredConsentsGiven(_values, policies)) ...[
                            const SizedBox(height: FieldnoteSpacing.xs),
                            Text(
                              l10n.consentCheckRequired,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: FieldnoteSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _saving ? null : _signOut,
                          icon: const Icon(Icons.logout),
                          label: Text(l10n.signOut),
                        ),
                        TextButton.icon(
                          onPressed: _saving
                              ? null
                              : () => confirmAndRequestAccountDeletion(
                                  context,
                                  _viewModel,
                                ),
                          style: TextButton.styleFrom(
                            foregroundColor: context.fieldnoteColors.danger,
                          ),
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.deletionDeleteMyAccount),
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
  final l10n = context.l10n;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => fieldnoteDialog(
      title: Text(
        allDevices ? l10n.signOutAllDevicesTitle : l10n.signOutTitle,
      ),
      content: Text(
        allDevices ? l10n.signOutAllDevicesBody : l10n.signOutBody,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            MaterialLocalizations.of(dialogContext).cancelButtonLabel,
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(allDevices ? l10n.signOutEverywhere : l10n.signOut),
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

/// Activity timestamps in the current locale.
DateFormat _activityTime(BuildContext context) =>
    DateFormat.yMMMd(context.localeTag).add_Hm();

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
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FieldnotePageList(
        children: [
          SectionHeading(
            eyebrow: l10n.trustEyebrow,
            title: l10n.trustTitle,
            description: l10n.trustDescription,
          ),
          const SizedBox(height: FieldnoteSpacing.md),
          if (trust == null)
            EmptyPanel(
              icon: Icons.shield_outlined,
              title: l10n.trustLoadingTitle,
              message: l10n.trustLoadingBody,
            )
          else ...[
            ResponsiveCardGrid(
              minimumItemWidth: 300,
              spacing: 14,
              children: [
                _ProtectionCard(
                  icon: Icons.payments_outlined,
                  title: l10n.trustVerifiedPayments,
                  detail: trust.paymentProtection,
                ),
                _ProtectionCard(
                  icon: Icons.gps_fixed,
                  title: l10n.trustLocationIntegrity,
                  detail: trust.locationProtection,
                ),
                _ProtectionCard(
                  icon: Icons.health_and_safety_outlined,
                  title: l10n.trustContentModeration,
                  detail: trust.moderationProtection,
                ),
              ],
            ),
            const SizedBox(height: FieldnoteSpacing.md),
            _privacyControls(context, trust),
            const SizedBox(height: FieldnoteSpacing.md),
            _consentHistory(context),
            const SizedBox(height: FieldnoteSpacing.md),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.trustSecurityActivity,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: FieldnoteSpacing.sm),
                  if (trust.recentEvents.isEmpty)
                    Text(l10n.trustNoSecurityEvents)
                  else ...[
                    for (final event in trust.recentEvents.take(3))
                      _activityTile(context, event),
                    if (trust.recentEvents.length > 3) ...[
                      const SizedBox(height: FieldnoteSpacing.xs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _showActivity(
                            context,
                            trust.recentEvents,
                          ),
                          icon: const Icon(Icons.history),
                          label: Text(
                            l10n.trustViewAllEvents(trust.recentEvents.length),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _privacyControls(BuildContext context, TrustCenterSummary trust) {
    final consent = viewModel.consent;
    final current = consentIsCurrent(consent, trust);
    final c = context.fieldnoteColors;
    final l10n = context.l10n;
    final time = _activityTime(context);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: c.forest,
              ),
              const SizedBox(width: FieldnoteSpacing.xs),
              Expanded(
                child: Text(
                  l10n.trustPrivacyControls,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: FieldnoteSpacing.xs),
          StatusPill(
            label: current
                ? l10n.trustConsentRecorded
                : consent == null
                ? l10n.trustNoConsent
                : l10n.trustConsentOutdated,
            color: current ? c.forest : c.clay,
            icon: current ? Icons.check_circle_outline : Icons.error_outline,
          ),
          if (consent != null) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(
              current
                  ? l10n.trustConsentAccepted(
                      time.format(consent.acceptedAt.toLocal()),
                      consent.privacyPolicyVersion,
                      consent.termsVersion,
                    )
                  : l10n.trustConsentLastUpdated(
                      time.format(consent.updatedAt.toLocal()),
                    ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: FieldnoteSpacing.sm),
          Text(trust.retentionNotice),
          const SizedBox(height: FieldnoteSpacing.xs),
          Text(
            l10n.trustCurrentVersions(
              trust.privacyPolicyVersion,
              trust.termsVersion,
            ),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          LegalLinks(
            policies: viewModel.legalPolicies,
            onRetry: viewModel.loadLegalPolicies,
          ),
          const SizedBox(height: FieldnoteSpacing.sm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _export(context),
                icon: const Icon(Icons.download_outlined),
                label: Text(l10n.trustExportData),
              ),
              if (current)
                OutlinedButton.icon(
                  onPressed: () => _withdraw(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.danger,
                  ),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: Text(l10n.trustWithdrawConsent),
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
            context.l10n.trustConsentHistory,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: FieldnoteSpacing.sm),
          if (history.isEmpty)
            Text(context.l10n.trustNoConsentChanges)
          else
            for (final entry in history.take(10)) _consentTile(context, entry),
        ],
      ),
    );
  }

  Widget _consentTile(BuildContext context, LegalConsentHistory entry) {
    final withdrawn = entry.action == 'withdrawn';
    final c = context.fieldnoteColors;
    final l10n = context.l10n;
    final granted = [
      if (entry.locationConsent) l10n.trustGrantedGps,
      if (entry.aiProcessingConsent) l10n.trustGrantedAi,
      if (entry.evidenceSharingConsent) l10n.trustGrantedEvidence,
    ];
    final summary = l10n.trustConsentHistoryEntry(
      _activityTime(context).format(entry.recordedAt.toLocal()),
      entry.privacyPolicyVersion,
      entry.termsVersion,
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        withdrawn ? Icons.remove_circle_outline : Icons.check_circle_outline,
        color: withdrawn ? c.clay : c.forest,
      ),
      title: Text(
        withdrawn ? l10n.trustConsentWithdrawn : l10n.trustConsentAcceptedTitle,
      ),
      subtitle: Text(
        granted.isEmpty ? summary : '$summary · ${granted.join(', ')}',
      ),
    );
  }

  Future<void> _withdraw(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => fieldnoteDialog(
        title: Text(l10n.trustWithdrawTitle),
        content: Text(l10n.trustWithdrawBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.trustKeepConsent),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            // A solid fill with white text in both brightnesses.
            style: FilledButton.styleFrom(
              backgroundColor: FieldnoteColors.danger,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.trustWithdraw),
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
          title: l10n.trustConsentNotWithdrawn,
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
    final c = context.fieldnoteColors;
    final l10n = context.l10n;
    final detail = event.detail.trim();
    final shownDetail = detail.isEmpty || detail.toLowerCase() == 'undefined'
        ? event.event == 'paymentCheckoutFailed'
              ? l10n.trustCheckoutDidNotComplete
              : ''
        : detail;
    final time = _activityTime(context).format(event.occurredAt.toLocal());
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        rejected ? Icons.gpp_bad_outlined : Icons.verified_user_outlined,
        color: rejected ? c.clay : c.forest,
      ),
      title: Text(_eventTitle(l10n, event.event)),
      subtitle: Text(
        shownDetail.isEmpty ? time : '$time · $shownDetail',
        maxLines: compact ? 2 : null,
        overflow: compact ? TextOverflow.ellipsis : null,
      ),
    );
  }

  void _showActivity(BuildContext context, List<AuditEvent> events) {
    showFieldnoteBottomSheet<void>(
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
              padding: FieldnoteSpacing.sheetPadding(
                context,
                bottom: FieldnoteSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.trustSecurityActivity,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(context.l10n.trustEventCount(events.length)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: FieldnoteSpacing.sheetPadding(context),
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

  static String _eventTitle(AppLocalizations l10n, String value) =>
      switch (value) {
        'paymentOrderCreated' => l10n.eventPaymentOrderCreated,
        'paymentSignatureVerified' => l10n.eventPaymentSignatureVerified,
        'paymentCheckoutFailed' => l10n.eventPaymentCheckoutFailed,
        'paymentVerifiedWithoutCredit' =>
          l10n.eventPaymentVerifiedWithoutCredit,
        'paymentOrderCreate' => l10n.eventPaymentOrderCreate,
        'locationCheckIn' => l10n.eventLocationCheckIn,
        'evidenceLocationIntegrity' => l10n.eventEvidenceLocationIntegrity,
        'evidenceSubmitted' => l10n.eventEvidenceSubmitted,
        'contentModeration' => l10n.eventContentModeration,
        'legalConsentAccepted' => l10n.trustConsentAcceptedTitle,
        'legalConsentWithdrawn' => l10n.trustConsentWithdrawn,
        'privacyDataExported' => l10n.eventPrivacyDataExported,
        'testPayoutSimulated' ||
        'testPayoutsSimulated' => l10n.eventTestPayoutSimulated,
        'accountDeletionRequested' => l10n.eventAccountDeletionRequested,
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
              Icon(icon, color: context.fieldnoteColors.forest, size: 23),
              const SizedBox(width: FieldnoteSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: FieldnoteSpacing.xs),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
