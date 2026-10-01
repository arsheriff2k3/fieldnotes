import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import 'volunteer_status.dart';

/// V-10: the volunteer's impact and full participation history, with their
/// own evidence and its review state.
class VolunteerHistoryScreen extends StatefulWidget {
  const VolunteerHistoryScreen({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  State<VolunteerHistoryScreen> createState() => _VolunteerHistoryScreenState();
}

class _VolunteerHistoryScreenState extends State<VolunteerHistoryScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_changed);
    _load();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await widget.viewModel.loadParticipationHistory();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.viewModel.participationHistory;
    final completed = history
        .where((e) => e.participation.status == ParticipationStatus.completed)
        .length;
    final approved = history
        .where((e) => e.evidence?.reviewState == ReviewState.approved)
        .length;
    return Scaffold(
      appBar: AppBar(title: const Text('My impact')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: FieldnotePageList(
          children: [
            const SectionHeading(
              eyebrow: 'Your record',
              title: 'Impact & history',
              description:
                  'Every campaign you joined, what happened, and how your '
                  'evidence was reviewed.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Stat(label: 'Campaigns joined', value: '${history.length}'),
                _Stat(label: 'Evidence submitted', value: '$completed'),
                _Stat(label: 'Approved by sponsors', value: '$approved'),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading && history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (history.isEmpty)
              const EmptyPanel(
                icon: Icons.history,
                title: 'No history yet',
                message: 'Campaigns you join will appear here.',
              )
            else
              for (final entry in history)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _HistoryCard(
                    entry: entry,
                    viewModel: widget.viewModel,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry, required this.viewModel});

  final ParticipationHistoryEntry entry;
  final FieldnoteViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final display = participationDisplay(entry.participation, entry.campaign);
    final evidence = entry.evidence;
    final date = DateFormat(
      'EEE, d MMM yyyy',
    ).format(entry.campaign.startsAt.toLocal());
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: StatusPill(
                  label: display.label,
                  color: display.color,
                  icon: display.icon,
                ),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              Text(date, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.campaign.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            entry.campaign.locationName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (evidence != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  _reviewIcon(evidence.reviewState),
                  size: 18,
                  color: _reviewColor(evidence.reviewState),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    reviewStateLabel(evidence.reviewState),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: _reviewColor(evidence.reviewState),
                    ),
                  ),
                ),
              ],
            ),
            if (evidence.reviewNote?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text('Sponsor note: ${evidence.reviewNote!.trim()}'),
            ],
            const SizedBox(height: 8),
            Text(evidence.confirmedSummary),
            const SizedBox(height: 4),
            Text(
              'Submitted ${DateFormat('d MMM, HH:mm').format(evidence.submittedAt.toLocal())}'
              '${evidence.aiGenerated ? ' · AI-assisted summary' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (evidence.photographPath != null && evidence.id != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _showPhoto(context, evidence.id!),
                icon: const Icon(Icons.photo_outlined),
                label: const Text('View my evidence photo'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _showPhoto(BuildContext context, int evidenceId) async {
    final url = viewModel.repository.evidenceUrl(evidenceId);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: FutureBuilder<String>(
          future: url,
          builder: (context, snapshot) {
            Widget body;
            if (snapshot.hasError) {
              body = Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  userMessageFor(
                    snapshot.error!,
                    fallback: 'Could not load the photo.',
                  ),
                ),
              );
            } else if (!snapshot.hasData) {
              body = const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              body = InteractiveViewer(
                child: Image.network(
                  snapshot.data!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Could not load the photo.'),
                  ),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: body),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static IconData _reviewIcon(ReviewState state) => switch (state) {
    ReviewState.approved => Icons.verified,
    ReviewState.rejected => Icons.block,
    ReviewState.changesRequested => Icons.rate_review_outlined,
    ReviewState.awaitingReview => Icons.hourglass_top,
  };

  static Color _reviewColor(ReviewState state) => switch (state) {
    ReviewState.approved => FieldnoteColors.forest,
    ReviewState.rejected => FieldnoteColors.danger,
    ReviewState.changesRequested => FieldnoteColors.clay,
    ReviewState.awaitingReview => FieldnoteColors.moss,
  };
}
