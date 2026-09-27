import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'account_data_export_view.dart';

class LegalConsentGate extends StatefulWidget {
  const LegalConsentGate({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  State<LegalConsentGate> createState() => _LegalConsentGateState();
}

class _LegalConsentGateState extends State<LegalConsentGate> {
  bool _location = false;
  bool _ai = false;
  bool _evidence = false;
  bool _saving = false;

  Future<void> _accept() async {
    if (!_location || !_ai || !_evidence) return;
    setState(() => _saving = true);
    try {
      final consent = await widget.viewModel.repository.acceptLegalConsent();
      await widget.viewModel.consentCompleted(consent);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save consent: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const SectionHeading(
                  eyebrow: 'Trust before action',
                  title: 'Review your privacy choices',
                  description:
                      'FieldNote uses location, AI, and private evidence to connect sponsorship with verified volunteer work.',
                ),
                const SizedBox(height: 18),
                SurfaceCard(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: _location,
                        title: const Text('Use GPS for matching and integrity'),
                        subtitle: const Text(
                          'Stores approximate check-in/evidence coordinates and integrity signals.',
                        ),
                        onChanged: (value) =>
                            setState(() => _location = value ?? false),
                      ),
                      CheckboxListTile(
                        value: _ai,
                        title: const Text('Use AI assistance'),
                        subtitle: const Text(
                          'Campaign text and evidence inputs can be sent to an AI provider for structured drafts.',
                        ),
                        onChanged: (value) =>
                            setState(() => _ai = value ?? false),
                      ),
                      CheckboxListTile(
                        value: _evidence,
                        title: const Text('Share evidence with sponsors'),
                        subtitle: const Text(
                          'Evidence is private and exposed only through temporary authenticated links.',
                        ),
                        onChanged: (value) =>
                            setState(() => _evidence = value ?? false),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'By continuing you accept the FieldNote Terms '
                          'v${widget.viewModel.trustCenter?.termsVersion ?? 'current'} '
                          'and Privacy Policy '
                          'v${widget.viewModel.trustCenter?.privacyPolicyVersion ?? 'current'}.',
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving || !_location || !_ai || !_evidence
                              ? null
                              : _accept,
                          icon: const Icon(Icons.shield_outlined),
                          label: Text(
                            _saving ? 'Saving…' : 'Accept and continue',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrustCenterView extends StatelessWidget {
  const TrustCenterView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final trust = viewModel.trustCenter;
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
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
            SurfaceCard(
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
                  const StatusPill(
                    label: 'Consent recorded',
                    color: FieldnoteColors.forest,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 12),
                  Text(trust.retentionNotice),
                  const SizedBox(height: 6),
                  Text(
                    'Policy ${trust.privacyPolicyVersion} · Terms ${trust.termsVersion}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _export(context),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('View and export my data'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
          ],
        ],
      ),
    );
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        rejected ? Icons.gpp_bad_outlined : Icons.verified_user_outlined,
        color: rejected ? FieldnoteColors.clay : FieldnoteColors.forest,
      ),
      title: Text(_eventTitle(event.event)),
      subtitle: shownDetail.isEmpty
          ? null
          : Text(
              shownDetail,
              maxLines: compact ? 1 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
            ),
      trailing: Text(
        DateFormat('HH:mm').format(event.occurredAt.toLocal()),
        style: Theme.of(context).textTheme.labelSmall,
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
