import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/fieldnote_repository.dart';
import '../../../l10n/l10n.dart';
import '../../core/widgets.dart';
import 'sponsor_formatting.dart';

String _error(Object error) => error is FieldnoteException
    ? error.message
    : 'Could not update payout records. Check the connection and try again.';

String payoutStatusLabel(BuildContext context, String status) =>
    switch (status) {
      'requested' => context.l10n.manualPayoutRequested,
      'processing' => context.l10n.manualPayoutProcessing,
      'paid' => context.l10n.manualPayoutPaid,
      'rejected' => context.l10n.manualPayoutRejected,
      _ => status,
    };

/// Exact integer-paise parsing; no floating-point money arithmetic.
int? payoutDeductionPaise(String text) {
  final value = text.trim();
  if (!RegExp(r'^\d{1,7}(\.\d{1,2})?$').hasMatch(value)) return null;
  final parts = value.split('.');
  return int.parse(parts[0]) * 100 +
      (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
}

class ManualPayoutPanel extends StatefulWidget {
  const ManualPayoutPanel({
    super.key,
    required this.campaignId,
    required this.repository,
  });
  final int campaignId;
  final FieldnoteRepository repository;
  @override
  State<ManualPayoutPanel> createState() => _ManualPayoutPanelState();
}

class _ManualPayoutPanelState extends State<ManualPayoutPanel> {
  ManualPayoutSummary? _summary;
  String? _errorMessage;
  String? _requestId;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final summary = await widget.repository.manualPayoutSummary(
        widget.campaignId,
      );
      if (mounted) setState(() => _summary = summary);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _request() async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => fieldnoteDialog(
        title: Text(context.l10n.manualPayoutRequest),
        content: Text(context.l10n.manualPayoutRequestNotice),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.sponsorReachCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.manualPayoutRequest),
          ),
        ],
      ),
    );
    if (agreed != true || !mounted) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    // Retained after an uncertain response, so retries cannot reserve twice.
    _requestId ??= const Uuid().v4();
    try {
      await widget.repository.requestManualPayout(
        widget.campaignId,
        _requestId!,
      );
      _requestId = null;
      await _load();
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = _summary;
    String money(int paise) => formatPaise(paise, localeTag: context.localeTag);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.manualPayoutFunds,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: _busy ? null : _load,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.manualPayoutRefresh,
              ),
            ],
          ),
          Text(l10n.manualPayoutRequestNotice),
          const SizedBox(height: FieldnoteSpacing.sm),
          if (_busy) const LinearProgressIndicator(),
          if (_errorMessage != null) ...[
            const SizedBox(height: FieldnoteSpacing.xs),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (summary != null) ...[
            const SizedBox(height: FieldnoteSpacing.sm),
            _amount(l10n.manualPayoutEligible, money(summary.eligiblePaise)),
            _amount(l10n.manualPayoutAvailable, money(summary.availablePaise)),
            _amount(l10n.manualPayoutReserved, money(summary.reservedPaise)),
            _amount(l10n.manualPayoutPaid, money(summary.paidPaise)),
            const SizedBox(height: FieldnoteSpacing.sm),
            FilledButton.icon(
              onPressed:
                  !_busy &&
                      summary.liveMode &&
                      summary.completed &&
                      summary.availablePaise > 0
                  ? _request
                  : null,
              icon: const Icon(Icons.account_balance_outlined),
              label: Text(l10n.manualPayoutRequest),
            ),
            if (!summary.liveMode) Text(l10n.manualPayoutLiveRequired),
            if (!summary.completed) Text(l10n.manualPayoutCompletionRequired),
            if (summary.requests.isNotEmpty) ...[
              const Divider(height: 28),
              Text(
                l10n.manualPayoutHistory,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final request in summary.requests)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${payoutStatusLabel(context, request.status)} · ${money(request.amountPaise)}',
                  ),
                  subtitle: Text(
                    [
                      '${request.requestedAt.toLocal()}',
                      '${l10n.manualPayoutGross}: ${money(request.grossAmountPaise)}',
                      '${l10n.manualPayoutDeductions}: ${money(request.deductionPaise)}',
                      if (request.reviewNote != null) request.reviewNote!,
                      if (request.bankTransferReference != null)
                        '${l10n.manualPayoutBankReference}: ${request.bankTransferReference}',
                    ].join('\n'),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _amount(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(title)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

/// Display is conditional; the server independently enforces the allowlist.
class PayoutOperationsButton extends StatelessWidget {
  const PayoutOperationsButton({super.key, required this.repository});
  final FieldnoteRepository repository;
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: repository.isPayoutOperator(),
    builder: (context, snapshot) => snapshot.data != true
        ? const SizedBox.shrink()
        : OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PayoutOperationsView(repository: repository),
              ),
            ),
            icon: const Icon(Icons.admin_panel_settings_outlined),
            label: Text(context.l10n.manualPayoutOperations),
          ),
  );
}

class PayoutOperationsView extends StatefulWidget {
  const PayoutOperationsView({super.key, required this.repository});
  final FieldnoteRepository repository;
  @override
  State<PayoutOperationsView> createState() => _PayoutOperationsViewState();
}

class _PayoutOperationsViewState extends State<PayoutOperationsView> {
  final _requests = <ManualPayoutRequest>[];
  bool _busy = false;
  bool _more = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool append = false}) async {
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final page = await widget.repository.manualPayoutRequests(
        offset: append ? _requests.length : 0,
      );
      if (mounted) {
        setState(() {
          if (!append) _requests.clear();
          _requests.addAll(page);
          _more = page.length == 50;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review(ManualPayoutRequest request, bool approve) async {
    final settlement = TextEditingController();
    final payee = TextEditingController();
    final deduction = TextEditingController(text: '0');
    final note = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => fieldnoteDialog(
        title: Text(
          approve
              ? context.l10n.manualPayoutApprove
              : context.l10n.manualPayoutReject,
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (approve) ...[
                    Text(context.l10n.manualPayoutReviewNotice),
                    const SizedBox(height: FieldnoteSpacing.fieldGap),
                    TextFormField(
                      controller: settlement,
                      decoration: InputDecoration(
                        labelText: context.l10n.manualPayoutSettlementReference,
                      ),
                      validator: _referenceValidator,
                    ),
                    const SizedBox(height: FieldnoteSpacing.fieldGap),
                    TextFormField(
                      controller: payee,
                      decoration: InputDecoration(
                        labelText: context.l10n.manualPayoutPayeeReference,
                      ),
                      validator: _referenceValidator,
                    ),
                    const SizedBox(height: FieldnoteSpacing.fieldGap),
                    TextFormField(
                      controller: deduction,
                      decoration: InputDecoration(
                        labelText: context.l10n.manualPayoutDeductionInput,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final paise = payoutDeductionPaise(value ?? '');
                        return paise == null ||
                                paise >= request.grossAmountPaise
                            ? context.l10n.manualPayoutInvalidAmount
                            : null;
                      },
                    ),
                  ],
                  const SizedBox(height: FieldnoteSpacing.fieldGap),
                  const SizedBox(height: FieldnoteSpacing.fieldGap),
                  const SizedBox(height: FieldnoteSpacing.fieldGap),
                  const SizedBox(height: FieldnoteSpacing.fieldGap),
                  TextFormField(
                    controller: note,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: context.l10n.manualPayoutReviewNote,
                    ),
                    validator: (v) => (v ?? '').trim().length < 3
                        ? context.l10n.manualPayoutRequired
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.sponsorReachCancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(
              approve
                  ? context.l10n.manualPayoutApprove
                  : context.l10n.manualPayoutReject,
            ),
          ),
        ],
      ),
    );
    if (agreed == true && mounted) {
      await _run(
        () => widget.repository.reviewManualPayout(
          request.id!,
          approve: approve,
          deductionPaise: approve ? payoutDeductionPaise(deduction.text)! : 0,
          settlementReference: settlement.text,
          payeeVerificationReference: payee.text,
          note: note.text,
        ),
      );
    }
    // The dialog's reverse transition still uses its text controllers.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    settlement.dispose();
    payee.dispose();
    deduction.dispose();
    note.dispose();
  }

  String? _referenceValidator(String? v) =>
      (v ?? '').trim().length < 3 || (v ?? '').trim().length > 120
      ? context.l10n.manualPayoutRequired
      : null;

  Future<void> _paid(ManualPayoutRequest request) async {
    final reference = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => fieldnoteDialog(
        title: Text(context.l10n.manualPayoutRecordPaid),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.manualPayoutPaidNotice),
              TextFormField(
                controller: reference,
                decoration: InputDecoration(
                  labelText: context.l10n.manualPayoutBankReference,
                ),
                validator: _referenceValidator,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.sponsorReachCancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(context.l10n.manualPayoutRecordPaid),
          ),
        ],
      ),
    );
    if (agreed == true && mounted) {
      await _run(
        () => widget.repository.recordManualPayoutPaid(
          request.id!,
          reference.text,
        ),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    reference.dispose();
  }

  Future<void> _run(Future<ManualPayoutRequest> Function() action) async {
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      await action();
      await _load();
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String money(int paise) => formatPaise(paise, localeTag: context.localeTag);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manualPayoutOperations),
        actions: [
          IconButton(
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.manualPayoutRefresh,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.manualPayoutOperationsNotice),
          if (_busy) const LinearProgressIndicator(),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (!_busy && _requests.isEmpty) Text(l10n.manualPayoutEmpty),
          for (final request in _requests)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.manualPayoutCampaign} #${request.campaignId} · ${payoutStatusLabel(context, request.status)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SelectableText(
                      '${l10n.manualPayoutCreator}: ${request.creatorAuthUserId}',
                    ),
                    Text(
                      '${l10n.manualPayoutGross}: ${money(request.grossAmountPaise)} · ${l10n.manualPayoutNet}: ${money(request.amountPaise)}',
                    ),
                    Text(
                      '${l10n.manualPayoutDeductions}: ${money(request.deductionPaise)}',
                    ),
                    Text('${request.requestedAt.toLocal()}'),
                    if (request.reviewNote != null) Text(request.reviewNote!),
                    if (request.settlementReference != null)
                      SelectableText(
                        '${l10n.manualPayoutSettlementReference}: ${request.settlementReference}',
                      ),
                    if (request.payeeVerificationReference != null)
                      SelectableText(
                        '${l10n.manualPayoutPayeeReference}: ${request.payeeVerificationReference}',
                      ),
                    if (request.bankTransferReference != null)
                      SelectableText(
                        '${l10n.manualPayoutBankReference}: ${request.bankTransferReference}',
                      ),
                    if (request.status == 'requested')
                      Wrap(
                        spacing: 12,
                        runSpacing: FieldnoteSpacing.sm,
                        children: [
                          FilledButton(
                            onPressed: _busy
                                ? null
                                : () => _review(request, true),
                            child: Text(l10n.manualPayoutApprove),
                          ),
                          OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () => _review(request, false),
                            child: Text(l10n.manualPayoutReject),
                          ),
                        ],
                      ),
                    if (request.status == 'processing')
                      FilledButton(
                        onPressed: _busy ? null : () => _paid(request),
                        child: Text(l10n.manualPayoutRecordPaid),
                      ),
                  ],
                ),
              ),
            ),
          if (_more)
            TextButton(
              onPressed: _busy ? null : () => _load(append: true),
              child: Text(l10n.manualPayoutLoadMore),
            ),
        ],
      ),
    );
  }
}
