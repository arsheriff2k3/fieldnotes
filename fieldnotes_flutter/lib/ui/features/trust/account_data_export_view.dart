import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/widgets.dart';
import '../shell/fieldnote_view_model.dart';

class AccountDataExportView extends StatefulWidget {
  const AccountDataExportView({super.key, required this.viewModel});

  final FieldnoteViewModel viewModel;

  @override
  State<AccountDataExportView> createState() => _AccountDataExportViewState();
}

class _AccountDataExportViewState extends State<AccountDataExportView> {
  _AccountExport? _export;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final raw = await widget.viewModel.exportMyData();
      if (mounted) setState(() => _export = _AccountExport.parse(raw));
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not load your data. Try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sharePdf() async {
    final data = _export;
    if (data == null || _busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await buildAccountDataPdf(data.raw);
      if (!mounted) return;
      await _shareFile(
        bytes,
        'fieldnote-my-data-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
        'application/pdf',
      );
    } catch (_) {
      if (mounted) _showError('Could not create the PDF. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareJson() async {
    final data = _export;
    if (data == null || _busy) return;
    try {
      await _shareFile(
        Uint8List.fromList(utf8.encode(data.raw)),
        'fieldnote-my-data-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json',
        'application/json',
      );
    } catch (_) {
      if (mounted) _showError('Could not share the JSON file. Try again.');
    }
  }

  Future<void> _shareFile(Uint8List bytes, String name, String mimeType) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: name, mimeType: mimeType)],
        fileNameOverrides: [name],
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final data = _export;
    return Scaffold(
      appBar: AppBar(title: const Text('My data')),
      body: SafeArea(
        child: FieldnotePageList(
          children: [
            const SectionHeading(
              eyebrow: 'Your account records',
              title: 'Your FieldNote data',
              description:
                  'Read your records here, or save a report to your phone.',
            ),
            const SizedBox(height: 18),
            if (_busy && data == null)
              const Center(child: CircularProgressIndicator()),
            if (_error != null) ...[
              SurfaceCard(child: Text(_error!)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
            if (data != null) ...[
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Save or share a readable report',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Prepared ${data.generatedLabel}. The PDF contains the records shown below.',
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _busy ? null : _sharePdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(
                        _busy ? 'Preparing PDF…' : 'Save or share PDF',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final section in data.sections.where(
                (section) => section.records.isNotEmpty,
              )) ...[
                SurfaceCard(
                  child: ExpansionTile(
                    initiallyExpanded: section.title == 'Profile',
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(section.title),
                    subtitle: Text(
                      '${section.records.length} ${section.records.length == 1 ? 'record' : 'records'}',
                    ),
                    children: [
                      for (final record in section.records)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(record.title),
                          subtitle: Text(record.details.join('\n')),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                'Private photographs are not included in this report. Shared files may contain personal details, so choose where to save them carefully.',
              ),
              const SizedBox(height: 16),
              SurfaceCard(
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Advanced export'),
                  subtitle: const Text('For moving data to another service'),
                  children: [
                    const Text(
                      'JSON is a machine-readable copy of these account records.',
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _shareJson,
                      icon: const Icon(Icons.code),
                      label: const Text('Save or share JSON'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExportRecord {
  const _ExportRecord(this.title, this.details);

  final String title;
  final List<String> details;
}

class _ExportSection {
  const _ExportSection(this.title, this.records);

  final String title;
  final List<_ExportRecord> records;
}

class _AccountExport {
  const _AccountExport(this.raw, this.generatedLabel, this.sections);

  final String raw;
  final String generatedLabel;
  final List<_ExportSection> sections;

  static _AccountExport parse(String raw) {
    final root = jsonDecode(raw) as Map<String, dynamic>;
    final profile = _map(root['profile']);
    final consent = _map(root['consent']);
    final availability = _map(root['availability']);
    final sections = <_ExportSection>[
      _ExportSection('Profile', [
        _ExportRecord(_value(profile, 'displayName'), [
          'Role: ${_value(profile, 'role')}',
          'City: ${_value(profile, 'city')}',
          if (_value(profile, 'contactPhone') != '—')
            'Contact phone: ${_value(profile, 'contactPhone')}',
          if (_value(profile, 'organizationName') != '—')
            'Organization: ${_value(profile, 'organizationName')}',
          if (_value(profile, 'interests') != '—')
            'Interests: ${_value(profile, 'interests')}',
          if (_value(profile, 'skills') != '—')
            'Skills: ${_value(profile, 'skills')}',
        ]),
      ]),
      _ExportSection(
        'Privacy choices',
        consent.isEmpty
            ? []
            : [
                _ExportRecord('Consent accepted ${_date(consent['acceptedAt'])}', [
                  'Location: ${_yesNo(consent['locationConsent'])}',
                  'AI processing: ${_yesNo(consent['aiProcessingConsent'])}',
                  'Evidence sharing: ${_yesNo(consent['evidenceSharingConsent'])}',
                  'Privacy policy: ${_value(consent, 'privacyPolicyVersion')}',
                  'Terms: ${_value(consent, 'termsVersion')}',
                ]),
              ],
      ),
      _ExportSection(
        'Volunteer availability',
        availability.isEmpty
            ? []
            : [
                _ExportRecord(_value(availability, 'locationLabel'), [
                  'Available: ${_yesNo(availability['isAvailable'])}',
                  'Available today: ${_yesNo(availability['availableToday'])}',
                  'Travel radius: ${_value(availability, 'maximumTravelKm')} km',
                  'Days: ${_value(availability, 'weekdays')}',
                  'Updated: ${_date(availability['updatedAt'])}',
                ]),
              ],
      ),
      _ExportSection(
        'Campaigns you created',
        _rows(
          root,
          'createdCampaigns',
          (m) => _ExportRecord(_value(m, 'name'), [
            'Location: ${_value(m, 'locationName')}',
            'Starts: ${_date(m['startsAt'])}',
            'Status: ${_value(m, 'readinessState')}',
            'Funding goal: INR ${_amount(m['fundingGoal'])}',
            'Description: ${_value(m, 'description')}',
          ]),
        ),
      ),
      _ExportSection(
        'Sponsorships',
        _rows(
          root,
          'sponsorships',
          (m) => _ExportRecord(_value(m, 'campaignName'), [
            'Amount: INR ${_amount(m['amount'])}',
            'Payment status: ${_value(m, 'paymentStatus')}',
            'Date: ${_date(m['createdAt'])}',
            if (_value(m, 'message') != '—') 'Message: ${_value(m, 'message')}',
          ]),
        ),
      ),
      _ExportSection(
        'Volunteer work',
        _rows(
          root,
          'participations',
          (m) => _ExportRecord(_value(m, 'campaignName'), [
            'Status: ${_value(m, 'status')}',
            'Joined: ${_date(m['joinedAt'])}',
            if (m['checkedInAt'] != null)
              'Checked in: ${_date(m['checkedInAt'])}',
            if (m['completedAt'] != null)
              'Completed: ${_date(m['completedAt'])}',
          ]),
        ),
      ),
      _ExportSection(
        'Evidence you submitted',
        _rows(
          root,
          'completionEvidence',
          (m) => _ExportRecord(_value(m, 'campaignName'), [
            'Submitted: ${_date(m['submittedAt'])}',
            'Your note: ${_value(m, 'originalNote')}',
            'Confirmed summary: ${_value(m, 'confirmedSummary')}',
            'Location check: ${_value(m, 'locationIntegrityStatus')}',
          ]),
        ),
      ),
      _ExportSection(
        'Campaign updates you posted',
        _rows(
          root,
          'campaignPosts',
          (m) => _ExportRecord(_value(m, 'title'), [
            _value(m, 'body'),
            'Posted: ${_date(m['createdAt'])}',
          ]),
        ),
      ),
      _ExportSection(
        'Test payout simulations',
        _rows(
          root,
          'testPayouts',
          (m) => _ExportRecord('INR ${_amount(m['amount'])}', [
            'Status: ${_value(m, 'status')}',
            'Simulated: ${_date(m['simulatedAt'])}',
            'No bank transfer was made.',
          ]),
        ),
      ),
      _ExportSection(
        'Test refunds',
        _rows(
          root,
          'testRefunds',
          (m) => _ExportRecord('INR ${_amount(m['amount'])}', [
            'Status: ${_value(m, 'status')}',
            'Recorded: ${_date(m['createdAt'])}',
          ]),
        ),
      ),
      _ExportSection(
        'Security activity',
        _rows(
          root,
          'securityActivity',
          (m) => _ExportRecord(_friendlyEvent(_value(m, 'event')), [
            'When: ${_date(m['occurredAt'])}',
            'Result: ${_value(m, 'outcome')}',
            if (_value(m, 'detail') != '—' &&
                _value(m, 'detail') != 'undefined')
              _value(m, 'detail'),
          ]),
        ),
      ),
    ];
    return _AccountExport(raw, _date(root['generatedAt']), sections);
  }

  static List<_ExportRecord> _rows(
    Map<String, dynamic> root,
    String key,
    _ExportRecord Function(Map<String, dynamic>) build,
  ) => (root[key] as List<dynamic>? ?? const [])
      .map((item) => build(_map(item)))
      .toList();

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map<String, dynamic> ? value : const {};

  static String _value(Map<String, dynamic> map, String key) {
    final value = map[key]?.toString().trim();
    return value == null || value.isEmpty ? '—' : value;
  }

  static String _date(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed == null
        ? '—'
        : DateFormat('d MMM yyyy, h:mm a').format(parsed.toLocal());
  }

  static String _amount(dynamic value) =>
      (value is num ? value : num.tryParse(value?.toString() ?? ''))
          ?.toStringAsFixed(2) ??
      '0.00';

  static String _yesNo(dynamic value) => value == true ? 'Yes' : 'No';

  static String _friendlyEvent(String value) => switch (value) {
    'paymentOrderCreated' => 'Payment started',
    'paymentSignatureVerified' => 'Payment verified',
    'paymentCheckoutFailed' => 'Checkout did not complete',
    'locationCheckIn' => 'Location check',
    'evidenceSubmitted' => 'Evidence submitted',
    'legalConsentAccepted' => 'Privacy choices accepted',
    'privacyDataExported' => 'Data export requested',
    'accountDeletionRequested' => 'Account deletion requested',
    _ => value,
  };
}

Future<Uint8List> buildAccountDataPdf(String raw) async {
  final data = _AccountExport.parse(raw);
  final base = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );
  final tamil = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSansTamil.ttf'),
  );
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      theme: pw.ThemeData.withFont(
        base: base,
        bold: base,
        fontFallback: [tamil],
      ),
      footer: (context) => pw.Text(
        'FieldNote account report  •  Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 8),
      ),
      build: (context) => [
        pw.Text(
          'My FieldNote data',
          style: pw.TextStyle(fontSize: 23, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Prepared ${data.generatedLabel}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 12),
        for (final section in data.sections.where(
          (section) => section.records.isNotEmpty,
        )) ...[
          pw.Header(level: 1, text: section.title),
          for (final record in section.records) ...[
            pw.Text(
              record.title,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            for (final detail in record.details)
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10, top: 2),
                child: pw.Text(detail),
              ),
            pw.SizedBox(height: 8),
          ],
        ],
        pw.SizedBox(height: 12),
        pw.Text('Private photographs are not embedded in this report.'),
      ],
    ),
  );
  return pdf.save();
}
