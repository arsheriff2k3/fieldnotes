import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fieldnote_theme.dart';

/// The consent switches `acceptLegalConsent` knows about, in display order.
/// Keys match `LegalPolicies.requiredConsents`.
const consentLocation = 'locationConsent';
const consentAiProcessing = 'aiProcessingConsent';
const consentEvidenceSharing = 'evidenceSharingConsent';

const allConsentKeys = [
  consentLocation,
  consentAiProcessing,
  consentEvidenceSharing,
];

class ConsentChoice {
  const ConsentChoice(this.key, this.title, this.description);

  final String key;
  final String title;
  final String description;
}

const consentChoices = [
  ConsentChoice(
    consentLocation,
    'Use GPS for matching and check-in integrity',
    'Stores approximate check-in and evidence coordinates and integrity '
        'signals.',
  ),
  ConsentChoice(
    consentAiProcessing,
    'Use AI assistance',
    'Campaign text and evidence inputs can be sent to an AI provider for '
        'structured drafts.',
  ),
  ConsentChoice(
    consentEvidenceSharing,
    'Share evidence privately with campaign sponsors',
    'Evidence is private and exposed only through temporary authenticated '
        'links.',
  ),
];

/// Consents the server requires; all three when the policies are unknown.
List<String> requiredConsentKeys(LegalPolicies? policies) {
  final required = policies?.requiredConsents;
  if (required == null || required.isEmpty) return allConsentKeys;
  return required;
}

/// True when every required consent in [values] is checked.
bool requiredConsentsGiven(Map<String, bool> values, LegalPolicies? policies) =>
    requiredConsentKeys(
      policies,
    ).every((key) => values[key] == true);

/// One checkbox per consent. Required consents are marked as such.
class ConsentChecklist extends StatelessWidget {
  const ConsentChecklist({
    super.key,
    required this.values,
    required this.onChanged,
    this.policies,
    this.enabled = true,
    this.showDescriptions = true,
  });

  final Map<String, bool> values;
  final void Function(String key, bool value) onChanged;
  final LegalPolicies? policies;
  final bool enabled;
  final bool showDescriptions;

  @override
  Widget build(BuildContext context) {
    final required = requiredConsentKeys(policies);
    // The tiles often sit on a decorated card; give their ink a Material.
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          for (final choice in consentChoices)
            CheckboxListTile(
              key: ValueKey('consent-${choice.key}'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: values[choice.key] ?? false,
              title: Text(
                required.contains(choice.key)
                    ? '${choice.title} (required)'
                    : choice.title,
              ),
              subtitle: showDescriptions ? Text(choice.description) : null,
              onChanged: enabled
                  ? (value) => onChanged(choice.key, value ?? false)
                  : null,
            ),
        ],
      ),
    );
  }
}

/// Opens [url] in the browser. When that is impossible, shows the URL with a
/// copy button instead.
Future<void> openLegalDocument(
  BuildContext context, {
  required String title,
  required String url,
}) async {
  var opened = false;
  final uri = Uri.tryParse(url);
  if (uri != null && uri.hasScheme) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      opened = false;
    }
  }
  if (opened || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Open this address in your browser to read it:'),
          const SizedBox(height: 8),
          SelectableText(url),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy link'),
        ),
      ],
    ),
  );
}

/// "Privacy Policy" and "Terms" links. While [policies] is null the links
/// are disabled and [onRetry] (if set) offers to load them again.
class LegalLinks extends StatelessWidget {
  const LegalLinks({
    super.key,
    required this.policies,
    this.onRetry,
    this.color,
    this.showVersions = false,
    this.alignment = WrapAlignment.start,
  });

  final LegalPolicies? policies;
  final VoidCallback? onRetry;
  final Color? color;
  final bool showVersions;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final value = policies;
    final style = TextButton.styleFrom(
      foregroundColor: color ?? FieldnoteColors.forest,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: const Size(48, 40),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        decoration: TextDecoration.underline,
      ),
    );
    if (value == null) {
      return Wrap(
        alignment: alignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Privacy Policy and Terms are loading…',
            style: TextStyle(color: color, fontSize: 12),
          ),
          if (onRetry != null)
            TextButton(
              style: style,
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      );
    }
    return Wrap(
      alignment: alignment,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Semantics(
          link: true,
          child: TextButton(
            style: style,
            onPressed: () => openLegalDocument(
              context,
              title: 'Privacy Policy',
              url: value.privacyPolicyUrl,
            ),
            child: Text(
              showVersions
                  ? 'Privacy Policy v${value.privacyPolicyVersion}'
                  : 'Privacy Policy',
            ),
          ),
        ),
        Semantics(
          link: true,
          child: TextButton(
            style: style,
            onPressed: () => openLegalDocument(
              context,
              title: 'Terms of Service',
              url: value.termsUrl,
            ),
            child: Text(
              showVersions ? 'Terms v${value.termsVersion}' : 'Terms',
            ),
          ),
        ),
      ],
    );
  }
}
