import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';

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
                        title: const Text('Use Gemini AI assistance'),
                        subtitle: const Text(
                          'Campaign text and evidence inputs can be sent to Gemini for structured drafts.',
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
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'By continuing you accept the FieldNote Terms and Privacy Policy v2026-09-22.',
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
            eyebrow: 'Trust & safety',
            title: 'Proof has a paper trail',
            description:
                'See how FieldNote protects payments, location evidence, AI content, and your privacy.',
          ),
          const SizedBox(height: 22),
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
                      const StatusPill(
                        label: 'Consent recorded',
                        color: FieldnoteColors.forest,
                        icon: Icons.check_circle_outline,
                      ),
                    ],
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
                        label: const Text('Export my data'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _requestDeletion(context),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Request deletion'),
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
                  else
                    ...trust.recentEvents
                        .take(12)
                        .map(
                          (event) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              event.outcome == 'rejected'
                                  ? Icons.gpp_bad_outlined
                                  : Icons.verified_user_outlined,
                              color: event.outcome == 'rejected'
                                  ? FieldnoteColors.clay
                                  : FieldnoteColors.forest,
                            ),
                            title: Text(_eventTitle(event.event)),
                            subtitle: Text(event.detail),
                            trailing: Text(
                              DateFormat(
                                'HH:mm',
                              ).format(event.occurredAt.toLocal()),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    try {
      final data = await viewModel.exportMyData();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Your FieldNote data'),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: SelectableText(data, style: const TextStyle(fontSize: 12)),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: data));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy JSON'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $error')),
        );
      }
    }
  }

  Future<void> _requestDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request account deletion?'),
        content: const Text(
          'The request is securely logged for review. Shared campaign records are retained until the request is processed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Record request'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await viewModel.requestAccountDeletion();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deletion request recorded.')),
      );
    }
  }

  static String _eventTitle(String value) => switch (value) {
    'paymentOrderCreated' => 'Razorpay order created',
    'paymentSignatureVerified' => 'Payment signature checked',
    'paymentCheckoutFailed' => 'Checkout failed or cancelled',
    'locationCheckIn' => 'Check-in integrity checked',
    'evidenceSubmitted' => 'Evidence verified',
    'contentModeration' => 'Content moderation decision',
    'legalConsentAccepted' => 'Consent accepted',
    'privacyDataExported' => 'Data exported',
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
          Icon(icon, color: FieldnoteColors.forest, size: 30),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 7),
          Text(detail),
        ],
      ),
    );
  }
}
