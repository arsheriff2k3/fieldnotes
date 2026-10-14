import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/models/campaign_impact_report.dart';

String reportUtcDate(DateTime date) {
  final utc = date.toUtc();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${utc.year}-${two(utc.month)}-${two(utc.day)} '
      '${two(utc.hour)}:${two(utc.minute)} UTC';
}

// ASCII currency label renders reliably in the bundled PDF font. Use integer
// paise throughout, including balances beyond exact double precision.
String reportMoney(int paise) {
  final absolute = paise.abs();
  return '${paise < 0 ? '-' : ''}INR ${absolute ~/ 100}.'
      '${(absolute % 100).toString().padLeft(2, '0')}';
}

const reportEvidenceNotice =
    'Contributions are volunteer-reported and sponsor-approved, not '
    'independently verified outcomes. Photos and location checks support a '
    'report; they do not establish every claimed quantity. No environmental '
    'or carbon totals are inferred.';

/// A multipage report without private photo URLs, exact GPS, original notes,
/// reviewer identifiers or volunteer identities. PDF labels remain English,
/// as in the account export, because Indic label shaping is not supported.
Future<Uint8List> buildCampaignImpactPdf(CampaignImpactReport report) async {
  final base = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );
  final tamil = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSansTamil.ttf'),
  );
  final devanagari = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSansDevanagari.ttf'),
  );
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      // Campaigns admit up to 500 volunteers; long reviewed summaries can
      // legitimately occupy many pages. Content widgets remain splittable.
      maxPages: 600,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: base,
        fontFallback: [tamil, devanagari],
      ),
      footer: (context) => pw.Text(
        'FieldNote | Campaign ${report.campaignId} | '
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 8),
      ),
      build: (context) => [
        pw.Text(
          'Campaign impact report',
          style: const pw.TextStyle(fontSize: 23),
        ),
        pw.SizedBox(height: 12),
        pw.Text(report.campaignName, style: const pw.TextStyle(fontSize: 18)),
        pw.Text('Campaign ID: ${report.campaignId}'),
        pw.Text('Location: ${report.locationName}'),
        pw.Text('Starts: ${reportUtcDate(report.startsAt)}'),
        if (report.endsAt != null)
          pw.Text('Ends: ${reportUtcDate(report.endsAt!)}'),
        pw.Text('Retrieved: ${reportUtcDate(report.retrievedAt)}'),
        pw.Header(level: 1, text: 'Recorded funding'),
        pw.Text('Net credited funding: ${reportMoney(report.netFundingPaise)}'),
        pw.Text('Funding goal: ${reportMoney(report.fundingGoalPaise)}'),
        pw.Text('Processed refunds: ${reportMoney(report.refundedPaise)}'),
        pw.Text(report.serverSummary),
        pw.Header(level: 1, text: 'Participation and evidence'),
        pw.Text('Active participants: ${report.joinedVolunteers}'),
        pw.Text('Submitted contributions: ${report.submittedCount}'),
        pw.Text('Sponsor-approved: ${report.approvedCount}'),
        pw.Text('Awaiting review: ${report.pendingCount}'),
        pw.Text('Changes requested: ${report.changesRequestedCount}'),
        pw.Text('Rejected: ${report.rejectedCount}'),
        pw.Text('Demo GPS evidence: ${report.demoEvidenceCount}'),
        pw.Header(level: 1, text: 'Sponsor-approved contributions'),
        if (report.contributions.isEmpty)
          pw.Text('No sponsor-approved contributions yet.'),
        for (final item in report.contributions) ...[
          pw.SizedBox(height: 12),
          pw.Text('Evidence #${item.id ?? 'unassigned'}'),
          pw.Text(item.summary),
          pw.Text('Submitted: ${reportUtcDate(item.submittedAt)}'),
          pw.Text(
            'Reviewed: ${item.reviewedAt == null ? 'Not recorded' : reportUtcDate(item.reviewedAt!)}',
          ),
          pw.Text(
            item.isDemo
                ? 'Demo GPS - simulated location'
                : 'Live GPS submission',
          ),
          pw.Text(item.aiGenerated ? 'AI-assisted summary' : 'Manual summary'),
        ],
        pw.Header(level: 1, text: 'Scope of this report'),
        pw.Text(reportEvidenceNotice),
        pw.SizedBox(height: 8),
        pw.Text(
          'This is a retrieved record. Later reviews and refunds can change '
          'the next report. Private photos and exact coordinates are omitted. '
          'Review summary text before sharing it outside the campaign team.',
        ),
      ],
    ),
  );
  return pdf.save();
}
