import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../../core/error_messages.dart';
import '../../core/fieldnote_theme.dart';
import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';
import '../discussion/campaign_discussion_view.dart';
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
    final l10n = context.l10n;
    final number = NumberFormat.decimalPattern(context.localeTag);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.volunteerHistoryAppBar)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: FieldnotePageList(
          children: [
            SectionHeading(
              eyebrow: l10n.volunteerHistoryEyebrow,
              title: l10n.volunteerHistoryTitle,
              description: l10n.volunteerHistoryDescription,
            ),
            const SizedBox(height: FieldnoteSpacing.md),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Stat(
                  label: l10n.volunteerHistoryStatJoined,
                  value: number.format(history.length),
                ),
                _Stat(
                  label: l10n.volunteerHistoryStatSubmitted,
                  value: number.format(completed),
                ),
                _Stat(
                  label: l10n.volunteerHistoryStatApproved,
                  value: number.format(approved),
                ),
              ],
            ),
            const SizedBox(height: FieldnoteSpacing.lg),
            if (_loading && history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (history.isEmpty)
              EmptyPanel(
                icon: Icons.history,
                title: l10n.volunteerHistoryEmptyTitle,
                message: l10n.volunteerHistoryEmptyMessage,
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
            const SizedBox(height: FieldnoteSpacing.xxs),
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
    final l10n = context.l10n;
    final locale = context.localeTag;
    final display = participationDisplay(
      entry.participation,
      entry.campaign,
      l10n: l10n,
    );
    final evidence = entry.evidence;
    final date = DateFormat.yMMMEd(
      dateLocale(locale),
    ).format(entry.campaign.startsAt.toLocal());
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (const {
            ParticipationStatus.completed,
            ParticipationStatus.incomplete,
          }.contains(entry.participation.status))
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => CampaignDiscussionView(
                    campaign: entry.campaign,
                    repository: viewModel.repository,
                    currentUserId: viewModel.profile?.authUserId,
                  ),
                ),
              ),
              icon: const Icon(Icons.forum_outlined),
              label: Text(context.l10n.campaignDiscussionTitle),
            ),
          Wrap(
            spacing: FieldnoteSpacing.sm,
            runSpacing: FieldnoteSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusPill(
                label: display.label,
                color: display.color,
                icon: display.icon,
              ),
              Text(date, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: FieldnoteSpacing.sm),
          Text(
            entry.campaign.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: FieldnoteSpacing.xxs),
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
                  color: context.fieldnoteColors.adapt(
                    _reviewColor(evidence.reviewState),
                  ),
                ),
                const SizedBox(width: FieldnoteSpacing.xs),
                Expanded(
                  child: Text(
                    reviewStateLabel(evidence.reviewState, l10n: l10n),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.fieldnoteColors.adapt(
                        _reviewColor(evidence.reviewState),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (evidence.reviewNote?.trim().isNotEmpty == true) ...[
              const SizedBox(height: FieldnoteSpacing.xs),
              Text(l10n.volunteerSponsorNote(evidence.reviewNote!.trim())),
            ],
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(evidence.confirmedSummary),
            const SizedBox(height: FieldnoteSpacing.xxs),
            Text(
              evidence.aiGenerated
                  ? l10n.volunteerSubmittedAtAi(
                      DateFormat.MMMd(
                        dateLocale(locale),
                      ).add_Hm().format(evidence.submittedAt.toLocal()),
                    )
                  : l10n.volunteerSubmittedAt(
                      DateFormat.MMMd(
                        dateLocale(locale),
                      ).add_Hm().format(evidence.submittedAt.toLocal()),
                    ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (evidence.photographPath != null && evidence.id != null) ...[
              const SizedBox(height: FieldnoteSpacing.xs),
              TextButton.icon(
                onPressed: () => _showPhoto(context, evidence.id!),
                icon: const Icon(Icons.photo_outlined),
                label: Text(l10n.volunteerViewEvidencePhoto),
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
                    fallback: context.l10n.volunteerPhotoLoadFailed,
                    context: context,
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
                  errorBuilder: (context, _, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(context.l10n.volunteerPhotoLoadFailed),
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
                    child: Text(context.l10n.commonClose),
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
