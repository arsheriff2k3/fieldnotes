import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../../l10n/l10n.dart';
import '../../core/error_messages.dart';
import 'campaign_discussion_model.dart';

class CampaignDiscussionView extends StatefulWidget {
  const CampaignDiscussionView({
    super.key,
    required this.campaign,
    required this.repository,
    required this.currentUserId,
  });

  final Campaign campaign;
  final FieldnoteRepository repository;
  final UuidValue? currentUserId;

  @override
  State<CampaignDiscussionView> createState() => _CampaignDiscussionViewState();
}

class _CampaignDiscussionViewState extends State<CampaignDiscussionView> {
  final _text = TextEditingController();
  late final CampaignDiscussionModel _model;

  @override
  void initState() {
    super.initState();
    _model = CampaignDiscussionModel(widget.repository, widget.campaign.id!)
      ..start();
  }

  @override
  void dispose() {
    _model.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final draft = _text.text;
    final sent = await _model.send(draft);
    if (!mounted) return;
    if (sent && _text.text == draft) _text.clear();
    if (!sent && _model.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessageFor(_model.error!, context: context)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.campaignDiscussionTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListenableBuilder(
              listenable: _model,
              builder: (context, _) {
                final messages = _model.messages;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.campaign.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(l10n.campaignDiscussionDescription),
                        ],
                      ),
                    ),
                    if (_model.accessDenied)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(l10n.campaignDiscussionNoAccess),
                      )
                    else if (!_model.connected)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(l10n.campaignDiscussionReconnecting),
                      )
                    else if (_model.readOnly)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(l10n.campaignDiscussionReadOnly),
                      ),
                    if (_model.error != null && !_model.accessDenied)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          userMessageFor(_model.error!, context: context),
                        ),
                      ),
                    Expanded(
                      child: _model.loading
                          ? const Center(child: CircularProgressIndicator())
                          : messages.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  _model.accessDenied
                                      ? l10n.campaignDiscussionNoAccess
                                      : l10n.campaignDiscussionEmpty,
                                ),
                              ),
                            )
                          : ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  messages.length + (_model.hasOlder ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == messages.length) {
                                  return TextButton(
                                    onPressed: _model.loadOlder,
                                    child: Text(l10n.campaignDiscussionOlder),
                                  );
                                }
                                final message = messages[index];
                                final mine =
                                    message.senderAuthUserId ==
                                    widget.currentUserId;
                                return Align(
                                  key: ValueKey(message.id),
                                  alignment: mine
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 560,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: mine
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer
                                          : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${mine ? l10n.campaignDiscussionYou : message.senderDisplayName} · ${message.senderIsCreator ? l10n.campaignDiscussionCampaigner : l10n.campaignDiscussionVolunteer}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        SelectableText(message.body),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat.MMMd(
                                            context.localeTag,
                                          ).add_Hm().format(
                                            message.createdAt.toLocal(),
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (!_model.accessDenied && !_model.readOnly)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _text,
                                enabled: !_model.sending,
                                minLines: 1,
                                maxLines: 4,
                                maxLength: 2000,
                                decoration: InputDecoration(
                                  labelText: l10n.campaignDiscussionCompose,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              tooltip: l10n.campaignDiscussionSend,
                              onPressed: !_model.connected || _model.sending
                                  ? null
                                  : _send,
                              icon: _model.sending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_outlined),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
