import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/widgets.dart';
import '../../../l10n/l10n.dart';
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
      if (mounted) {
        setState(
          () => _export = _AccountExport.parse(
            raw,
            context.l10n,
            context.localeTag,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.exportLoadFailed);
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
      final bytes = await buildAccountDataPdf(
        data.raw,
        l10n: context.l10n,
        locale: context.localeTag,
      );
      if (!mounted) return;
      await _shareFile(
        bytes,
        'fieldnote-my-data-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
        'application/pdf',
        'pdf',
      );
    } catch (_) {
      if (mounted) _showError(context.l10n.exportPdfFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareJson() async {
    final data = _export;
    if (data == null || _busy) return;
    setState(() => _busy = true);
    try {
      await _shareFile(
        Uint8List.fromList(utf8.encode(data.raw)),
        'fieldnote-my-data-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json',
        'application/json',
        'json',
      );
    } catch (_) {
      if (mounted) _showError(context.l10n.exportJsonFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareFile(
    Uint8List bytes,
    String name,
    String mimeType,
    String format,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: name, mimeType: mimeType)],
        fileNameOverrides: [name],
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
    if (result.status == ShareResultStatus.success) {
      await widget.viewModel.recordAccountDataExport(format);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final data = _export;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportAppBarTitle)),
      body: SafeArea(
        child: FieldnotePageList(
          children: [
            SectionHeading(
              eyebrow: l10n.exportEyebrow,
              title: l10n.exportTitle,
              description: l10n.exportDescription,
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
                label: Text(l10n.commonTryAgain),
              ),
            ],
            if (data != null) ...[
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.exportReportTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.exportPreparedAt(data.generatedLabel),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _busy ? null : _sharePdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(
                        _busy ? l10n.exportPreparingPdf : l10n.exportSharePdf,
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
                    initiallyExpanded: section.id == _SectionId.profile,
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(section.title),
                    subtitle: Text(
                      l10n.exportRecordCount(section.records.length),
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
              Text(l10n.exportPhotosNotice),
              const SizedBox(height: 16),
              SurfaceCard(
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(l10n.exportAdvancedTitle),
                  subtitle: Text(l10n.exportAdvancedSubtitle),
                  children: [
                    Text(l10n.exportJsonDescription),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _shareJson,
                      icon: const Icon(Icons.code),
                      label: Text(l10n.exportShareJson),
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

enum _SectionId {
  profile,
  privacy,
  availability,
  createdCampaigns,
  sponsorships,
  participations,
  evidence,
  posts,
  payouts,
  refunds,
  security,
}

class _ExportRecord {
  const _ExportRecord(this.title, this.details);

  final String title;
  final List<String> details;
}

class _ExportSection {
  const _ExportSection(this.id, this.title, this.records);

  final _SectionId id;
  final String title;
  final List<_ExportRecord> records;
}

/// The account export as readable sections. Labels and dates are worded in
/// [l10n] / [locale]; stored values (roles, statuses, tags) stay as stored.
class _AccountExport {
  const _AccountExport(this.raw, this.generatedLabel, this.sections);

  final String raw;
  final String generatedLabel;
  final List<_ExportSection> sections;

  static _AccountExport parse(
    String raw,
    AppLocalizations l10n,
    String locale,
  ) {
    final root = jsonDecode(raw) as Map<String, dynamic>;
    final profile = _map(root['profile']);
    final consent = _map(root['consent']);
    final availability = _map(root['availability']);
    // English uses intl's built-in default, which needs no initialisation.
    final dateFormat = DateFormat.yMMMd(
      locale == 'en' || locale.startsWith('en-') ? null : locale,
    ).add_jm();
    String date(dynamic value) {
      final parsed = DateTime.tryParse(value?.toString() ?? '');
      return parsed == null ? '—' : dateFormat.format(parsed.toLocal());
    }

    final number = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    String amount(dynamic value) => number.format(
      (value is num ? value : num.tryParse(value?.toString() ?? '')) ?? 0,
    );
    String yesNo(dynamic value) =>
        value == true ? l10n.commonYes : l10n.commonNo;

    final sections = <_ExportSection>[
      _ExportSection(_SectionId.profile, l10n.exportSectionProfile, [
        _ExportRecord(_value(profile, 'displayName'), [
          l10n.exportFieldRole(_value(profile, 'role')),
          l10n.exportFieldCity(_value(profile, 'city')),
          if (_value(profile, 'contactPhone') != '—')
            l10n.exportFieldContactPhone(_value(profile, 'contactPhone')),
          if (_value(profile, 'organizationName') != '—')
            l10n.exportFieldOrganization(_value(profile, 'organizationName')),
          if (_value(profile, 'interests') != '—')
            l10n.exportFieldInterests(_value(profile, 'interests')),
          if (_value(profile, 'skills') != '—')
            l10n.exportFieldSkills(_value(profile, 'skills')),
        ]),
      ]),
      _ExportSection(
        _SectionId.privacy,
        l10n.exportSectionPrivacy,
        consent.isEmpty
            ? []
            : [
                _ExportRecord(
                  l10n.exportConsentAccepted(date(consent['acceptedAt'])),
                  [
                    l10n.exportFieldLocation(yesNo(consent['locationConsent'])),
                    l10n.exportFieldAiProcessing(
                      yesNo(consent['aiProcessingConsent']),
                    ),
                    l10n.exportFieldEvidenceSharing(
                      yesNo(consent['evidenceSharingConsent']),
                    ),
                    l10n.exportFieldPrivacyPolicy(
                      _value(consent, 'privacyPolicyVersion'),
                    ),
                    l10n.exportFieldTerms(_value(consent, 'termsVersion')),
                  ],
                ),
              ],
      ),
      _ExportSection(
        _SectionId.availability,
        l10n.exportSectionAvailability,
        availability.isEmpty
            ? []
            : [
                _ExportRecord(_value(availability, 'locationLabel'), [
                  l10n.exportFieldAvailable(yesNo(availability['isAvailable'])),
                  l10n.exportFieldAvailableToday(
                    yesNo(availability['availableToday']),
                  ),
                  l10n.exportFieldTravelRadius(
                    _value(availability, 'maximumTravelKm'),
                  ),
                  l10n.exportFieldDays(_value(availability, 'weekdays')),
                  l10n.exportFieldUpdated(date(availability['updatedAt'])),
                ]),
              ],
      ),
      _ExportSection(
        _SectionId.createdCampaigns,
        l10n.exportSectionCreatedCampaigns,
        _rows(
          root,
          'createdCampaigns',
          (m) => _ExportRecord(_value(m, 'name'), [
            l10n.exportFieldLocation(_value(m, 'locationName')),
            l10n.exportFieldStarts(date(m['startsAt'])),
            l10n.exportFieldStatus(_value(m, 'readinessState')),
            l10n.exportFieldFundingGoal(amount(m['fundingGoal'])),
            l10n.exportFieldDescription(_value(m, 'description')),
          ]),
        ),
      ),
      _ExportSection(
        _SectionId.sponsorships,
        l10n.exportSectionSponsorships,
        _rows(
          root,
          'sponsorships',
          (m) => _ExportRecord(_value(m, 'campaignName'), [
            l10n.exportFieldAmount(amount(m['amount'])),
            l10n.exportFieldPaymentStatus(_value(m, 'paymentStatus')),
            l10n.exportFieldDate(date(m['createdAt'])),
            if (_value(m, 'message') != '—')
              l10n.exportFieldMessage(_value(m, 'message')),
          ]),
        ),
      ),
      _ExportSection(
        _SectionId.participations,
        l10n.exportSectionVolunteerWork,
        _rows(
          root,
          'participations',
          (m) => _ExportRecord(_value(m, 'campaignName'), [
            l10n.exportFieldStatus(_value(m, 'status')),
            l10n.exportFieldJoined(date(m['joinedAt'])),
            if (m['checkedInAt'] != null)
              l10n.exportFieldCheckedIn(date(m['checkedInAt'])),
            if (m['completedAt'] != null)
              l10n.exportFieldCompleted(date(m['completedAt'])),
          ]),
        ),
      ),
      _ExportSection(
        _SectionId.evidence,
        l10n.exportSectionEvidence,
        _rows(
          root,
          'completionEvidence',
          (m) => _ExportRecord(_value(m, 'campaignName'), [
            l10n.exportFieldSubmitted(date(m['submittedAt'])),
            l10n.exportFieldYourNote(_value(m, 'originalNote')),
            l10n.exportFieldConfirmedSummary(_value(m, 'confirmedSummary')),
            l10n.exportFieldLocationCheck(
              _value(m, 'locationIntegrityStatus'),
            ),
          ]),
        ),
      ),
      _ExportSection(
        _SectionId.posts,
        l10n.exportSectionPosts,
        _rows(
          root,
          'campaignPosts',
          (m) => _ExportRecord(_value(m, 'title'), [
            _value(m, 'body'),
            l10n.exportFieldPosted(date(m['createdAt'])),
          ]),
        ),
      ),
      _ExportSection(
        _SectionId.payouts,
        l10n.exportSectionPayouts,
        _rows(
          root,
          'testPayouts',
          (m) => _ExportRecord(l10n.exportInrAmount(amount(m['amount'])), [
            l10n.exportFieldStatus(_value(m, 'status')),
            l10n.exportFieldSimulated(date(m['simulatedAt'])),
            l10n.exportNoBankTransfer,
          ]),
        ),
      ),
      _ExportSection(
        _SectionId.refunds,
        l10n.exportSectionRefunds,
        _rows(
          root,
          'testRefunds',
          (m) => _ExportRecord(l10n.exportInrAmount(amount(m['amount'])), [
            l10n.exportFieldStatus(_value(m, 'status')),
            l10n.exportFieldRecorded(date(m['createdAt'])),
          ]),
        ),
      ),
      _ExportSection(
        _SectionId.security,
        l10n.exportSectionSecurity,
        _rows(
          root,
          'securityActivity',
          (m) => _ExportRecord(_friendlyEvent(l10n, _value(m, 'event')), [
            l10n.exportFieldWhen(date(m['occurredAt'])),
            l10n.exportFieldResult(_value(m, 'outcome')),
            if (_value(m, 'detail') != '—' &&
                _value(m, 'detail') != 'undefined')
              _value(m, 'detail'),
          ]),
        ),
      ),
    ];
    return _AccountExport(raw, date(root['generatedAt']), sections);
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

  static String _friendlyEvent(AppLocalizations l10n, String value) =>
      switch (value) {
        'paymentOrderCreated' => l10n.exportEventPaymentStarted,
        'paymentSignatureVerified' => l10n.exportEventPaymentVerified,
        'paymentCheckoutFailed' => l10n.trustCheckoutDidNotComplete,
        'locationCheckIn' => l10n.exportEventLocationCheck,
        'evidenceSubmitted' => l10n.exportEventEvidenceSubmitted,
        'legalConsentAccepted' => l10n.exportEventConsentAccepted,
        'privacyDataExported' => l10n.eventPrivacyDataExported,
        'accountDeletionRequested' => l10n.exportEventDeletionRequested,
        _ => value,
      };
}

final _englishStrings = lookupAppLocalizations(const Locale('en'));

/// Locales whose labels the PDF may use. The `pdf` package shapes only
/// Latin-like and Arabic text: Devanagari and Tamil labels would be drawn
/// with misplaced vowel signs and no conjuncts, so those reports keep
/// English labels. User-entered text in those scripts is still embedded with
/// the Noto fallback fonts.
bool _pdfCanRenderLabels(String localeName) => localeName.startsWith('en');

/// Loads a bundled font, or null when the asset is not in this build.
Future<pw.Font?> _optionalFont(String asset) async {
  try {
    return pw.Font.ttf(await rootBundle.load(asset));
  } on Object {
    return null;
  }
}

/// Builds the readable account report. [l10n] and [locale] word the labels
/// and dates when the PDF can render that script (see
/// [_pdfCanRenderLabels]); otherwise the report is English.
Future<Uint8List> buildAccountDataPdf(
  String raw, {
  AppLocalizations? l10n,
  String? locale,
}) async {
  final usable = l10n != null && _pdfCanRenderLabels(l10n.localeName);
  final strings = usable ? l10n : _englishStrings;
  final tag = usable ? (locale ?? l10n.localeName) : 'en';
  final data = _AccountExport.parse(raw, strings, tag);
  final base = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );
  final tamil = pw.Font.ttf(
    await rootBundle.load('assets/fonts/NotoSansTamil.ttf'),
  );
  final devanagari = await _optionalFont(
    'assets/fonts/NotoSansDevanagari.ttf',
  );
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      theme: pw.ThemeData.withFont(
        base: base,
        bold: base,
        fontFallback: [tamil, ?devanagari],
      ),
      footer: (context) => pw.Text(
        strings.exportPdfFooter(context.pageNumber, context.pagesCount),
        style: const pw.TextStyle(fontSize: 8),
      ),
      build: (context) => [
        pw.Text(
          strings.exportPdfTitle,
          style: pw.TextStyle(fontSize: 23, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          strings.exportPdfPrepared(data.generatedLabel),
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
        pw.Text(strings.exportPdfPhotosNotice),
      ],
    ),
  );
  return pdf.save();
}
