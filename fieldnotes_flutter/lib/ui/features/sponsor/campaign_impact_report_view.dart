import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/campaign_impact_report.dart';
import '../../../data/repositories/fieldnote_repository.dart';
import '../../../l10n/l10n.dart';
import '../../core/widgets.dart';
import 'campaign_impact_report.dart';
import 'sponsor_formatting.dart';

class CampaignImpactReportView extends StatefulWidget {
  const CampaignImpactReportView({
    super.key,
    required this.campaignId,
    required this.repository,
  });

  final int campaignId;
  final FieldnoteRepository repository;

  @override
  State<CampaignImpactReportView> createState() =>
      _CampaignImpactReportViewState();
}

class _CampaignImpactReportViewState extends State<CampaignImpactReportView> {
  CampaignImpactReport? _report;
  String? _error;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      // Never offer a stale export after a failed refresh or revoked access.
      _report = null;
    });
    try {
      final report = await widget.repository.campaignImpactReport(
        widget.campaignId,
      );
      if (mounted) setState(() => _report = report);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = sponsorErrorMessage(
            error,
            context: context,
            fallback: context.l10n.impactReportLoadFailed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _export() async {
    if (_report == null || _exporting || _loading) return;
    setState(() => _exporting = true);
    try {
      // Re-authorize and refresh before exporting; do not export stale reviews.
      final fresh = await widget.repository.campaignImpactReport(
        widget.campaignId,
      );
      if (!mounted) return;
      setState(() => _report = fresh);
      final bytes = await buildCampaignImpactPdf(fresh);
      if (!mounted) return;
      final name = 'fieldnote-campaign-${fresh.campaignId}-impact.pdf';
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes, name: name, mimeType: 'application/pdf'),
          ],
          fileNameOverrides: [name],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.impactReportExportFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final report = _report;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.impactReportTitle),
        actions: [
          IconButton(
            tooltip: l10n.impactReportRefresh,
            onPressed: _loading || _exporting ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      TextButton(
                        onPressed: _load,
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                ),
              )
            : report == null
            ? const SizedBox.shrink()
            : FieldnotePageList(
                children: [
                  Text(
                    report.campaignName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(report.locationName),
                  Text(
                    '${l10n.impactReportStarts}: ${reportUtcDate(report.startsAt)}',
                  ),
                  if (report.endsAt != null)
                    Text(
                      '${l10n.impactReportEnds}: ${reportUtcDate(report.endsAt!)}',
                    ),
                  Text(
                    '${l10n.impactReportRetrieved}: ${reportUtcDate(report.retrievedAt)}',
                  ),
                  const SizedBox(height: FieldnoteSpacing.md),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _metric(
                          l10n.impactReportNetFunding,
                          reportMoney(report.netFundingPaise),
                        ),
                        _metric(
                          l10n.impactReportGoal,
                          reportMoney(report.fundingGoalPaise),
                        ),
                        _metric(
                          l10n.impactReportRefunds,
                          reportMoney(report.refundedPaise),
                        ),
                        const Divider(),
                        Text(report.serverSummary),
                      ],
                    ),
                  ),
                  const SizedBox(height: FieldnoteSpacing.md),
                  SurfaceCard(
                    child: Column(
                      children: [
                        _metric(
                          l10n.impactReportParticipants,
                          '${report.joinedVolunteers}',
                        ),
                        _metric(
                          l10n.impactReportSubmitted,
                          '${report.submittedCount}',
                        ),
                        _metric(
                          l10n.impactReportApproved,
                          '${report.approvedCount}',
                        ),
                        _metric(
                          l10n.impactReportPending,
                          '${report.pendingCount}',
                        ),
                        _metric(
                          l10n.impactReportChanges,
                          '${report.changesRequestedCount}',
                        ),
                        _metric(
                          l10n.impactReportRejected,
                          '${report.rejectedCount}',
                        ),
                        _metric(
                          l10n.impactReportDemoCount,
                          '${report.demoEvidenceCount}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FieldnoteSpacing.md),
                  Text(
                    l10n.impactReportApproved,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (report.contributions.isEmpty)
                    Text(l10n.impactReportEmpty),
                  for (final item in report.contributions)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.impactReportEvidence} #${item.id ?? '—'}',
                            ),
                            Text(item.summary),
                            Text(
                              '${l10n.impactReportSubmittedAt}: ${reportUtcDate(item.submittedAt)}',
                            ),
                            Text(
                              '${l10n.impactReportReviewedAt}: ${item.reviewedAt == null ? l10n.impactReportNotRecorded : reportUtcDate(item.reviewedAt!)}',
                            ),
                            Text(
                              item.isDemo
                                  ? l10n.impactReportDemoGps
                                  : l10n.impactReportLiveGps,
                            ),
                            Text(
                              item.aiGenerated
                                  ? l10n.impactReportAiSummary
                                  : l10n.impactReportManualSummary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: FieldnoteSpacing.md),
                  Text(l10n.impactReportEvidenceNotice),
                  const SizedBox(height: FieldnoteSpacing.xs),
                  Text(l10n.impactReportSharingNotice),
                  const SizedBox(height: FieldnoteSpacing.md),
                  FilledButton.icon(
                    onPressed: _exporting ? null : _export,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(
                      _exporting
                          ? l10n.exportPreparingPdf
                          : l10n.exportSharePdf,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _metric(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: FieldnoteSpacing.sm),
        Flexible(child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
}
