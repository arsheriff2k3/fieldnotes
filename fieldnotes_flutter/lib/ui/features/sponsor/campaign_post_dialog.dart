import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';

import '../../core/error_messages.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'sponsor_formatting.dart';

/// Lets a campaign creator publish an official update that the campaign's
/// volunteers and funders read (S-9). Returns the post, or null if cancelled.
Future<CampaignPost?> showCampaignPostDialog(
  BuildContext context, {
  required FieldnoteViewModel viewModel,
  required Campaign campaign,
}) {
  return showDialog<CampaignPost>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        _CampaignPostDialog(viewModel: viewModel, campaign: campaign),
  );
}

class _CampaignPostDialog extends StatefulWidget {
  const _CampaignPostDialog({required this.viewModel, required this.campaign});

  final FieldnoteViewModel viewModel;
  final Campaign campaign;

  @override
  State<_CampaignPostDialog> createState() => _CampaignPostDialogState();
}

class _CampaignPostDialogState extends State<_CampaignPostDialog> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.length < CampaignLimits.postTitleMin ||
        title.length > CampaignLimits.postTitleMax) {
      setState(
        () => _error =
            'Give the update a title of ${CampaignLimits.postTitleMin}–'
            '${CampaignLimits.postTitleMax} characters.',
      );
      return;
    }
    if (body.length < CampaignLimits.postBodyMin ||
        body.length > CampaignLimits.postBodyMax) {
      setState(
        () => _error =
            'Write ${CampaignLimits.postBodyMin}–${CampaignLimits.postBodyMax} '
            'characters for the update.',
      );
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final post = await widget.viewModel.createCampaignPost(
        widget.campaign.id!,
        title,
        body,
      );
      if (mounted) Navigator.pop(context, post);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = userMessageFor(
            error,
            fallback: 'Could not publish the update.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dirty = _title.text.isNotEmpty || _body.text.isNotEmpty;
    return PopScope(
      canPop: !_sending && !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _sending) return;
        final discard = await confirmDiscard(context);
        if (discard && context.mounted) Navigator.pop(context);
      },
      child: AlertDialog(
        scrollable: true,
        title: const Text('Post an update'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Volunteers and sponsors of ${widget.campaign.name} will see '
                'this update.',
              ),
              const SizedBox(height: 14),
              FieldnoteTextField(
                controller: _title,
                enabled: !_sending,
                maxLength: CampaignLimits.postTitleMax,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              FieldnoteTextField(
                controller: _body,
                enabled: !_sending,
                minLines: 4,
                maxLines: 8,
                maxLength: CampaignLimits.postBodyMax,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Update'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _sending ? null : () => Navigator.maybePop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(_sending ? 'Publishing…' : 'Publish update'),
          ),
        ],
      ),
    );
  }
}

/// Asks whether unsaved form input may be thrown away.
Future<bool> confirmDiscard(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Discard changes?'),
      content: const Text('What you entered in this form will be lost.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Keep editing'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return result ?? false;
}
