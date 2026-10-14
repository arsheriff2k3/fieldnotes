import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/ui/features/sponsor/manual_payout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repository extends FieldnoteRepository {
  bool live = true;
  bool failNext = false;
  final ids = <String>[];
  final requests = <ManualPayoutRequest>[];

  @override
  Future<ManualPayoutSummary> manualPayoutSummary(int campaignId) async =>
      ManualPayoutSummary(
        campaignId: campaignId,
        liveMode: live,
        completed: true,
        eligiblePaise: 50000,
        availablePaise: requests.isEmpty ? 50000 : 0,
        reservedPaise: requests.isEmpty ? 0 : 50000,
        paidPaise: 0,
        requests: requests,
      );

  @override
  Future<ManualPayoutRequest> requestManualPayout(
    int campaignId,
    String clientRequestId,
  ) async {
    ids.add(clientRequestId);
    if (failNext) {
      failNext = false;
      throw Exception('Response lost');
    }
    final request = ManualPayoutRequest(
      id: 1,
      campaignId: campaignId,
      creatorAuthUserId: UuidValue.withValidation(
        '550e8400-e29b-41d4-a716-446655440000',
      ),
      clientRequestId: clientRequestId,
      sponsorshipIds: [1],
      grossAmountPaise: 50000,
      amountPaise: 50000,
    );
    requests.add(request);
    return request;
  }

  @override
  Future<List<ManualPayoutRequest>> manualPayoutRequests({
    int limit = 50,
    int offset = 0,
  }) async => requests;

  @override
  Future<ManualPayoutRequest> reviewManualPayout(
    int requestId, {
    required bool approve,
    required int deductionPaise,
    required String settlementReference,
    required String payeeVerificationReference,
    required String note,
  }) async {
    final updated = requests.single.copyWith(
      status: approve ? 'processing' : 'rejected',
      deductionPaise: deductionPaise,
      amountPaise: 50000 - deductionPaise,
      settlementReference: settlementReference,
      payeeVerificationReference: payeeVerificationReference,
      reviewNote: note,
    );
    requests[0] = updated;
    return updated;
  }

  @override
  Future<ManualPayoutRequest> recordManualPayoutPaid(
    int requestId,
    String reference,
  ) async {
    final updated = requests.single.copyWith(
      status: 'paid',
      bankTransferReference: reference,
    );
    requests[0] = updated;
    return updated;
  }
}

Future<void> _pump(WidgetTester tester, _Repository repository) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ManualPayoutPanel(campaignId: 1, repository: repository),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _request(WidgetTester tester) async {
  await tester.tap(find.text('Request payout'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Request payout'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('fee parsing preserves paise and rejects malformed input', () {
    expect(payoutDeductionPaise('10.05'), 1005);
    expect(payoutDeductionPaise('0.1'), 10);
    expect(payoutDeductionPaise('10'), 1000);
    for (final value in ['-1', '1.001', 'NaN', '1e3', '1,000', '']) {
      expect(payoutDeductionPaise(value), isNull);
    }
  });

  testWidgets('request confirmation reserves funds and displays history', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await _request(tester);
    expect(repository.requests.length, 1);
    expect(find.textContaining('Requested ·'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Request payout'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets(
    'retry after an uncertain response uses the same request identifier',
    (tester) async {
      final repository = _Repository()..failNext = true;
      await _pump(tester, repository);
      await _request(tester);
      await _request(tester);
      expect(repository.ids.length, 2);
      expect(repository.ids[0], repository.ids[1]);
    },
  );

  testWidgets('Test Mode never enables a real payout request', (tester) async {
    await _pump(tester, _Repository()..live = false);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Request payout'),
    );
    expect(button.onPressed, isNull);
    expect(
      find.textContaining('Real requests require Razorpay Live keys'),
      findsOneWidget,
    );
  });
  testWidgets(
    'operations verifies settlement and payee, then records a bank transfer',
    (tester) async {
      final repository = _Repository();
      await repository.requestManualPayout(1, 'request');
      await tester.pumpWidget(
        MaterialApp(home: PayoutOperationsView(repository: repository)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve for transfer'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Settlement verification reference'),
        'settled-123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Payee verification reference'),
        'payee-123',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Agreed deductions in INR (e.g. 10.50)',
        ),
        '10.50',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Creator-visible review note and fee explanation',
        ),
        'Agreed transfer fee',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Approve for transfer'),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.requests.single.status, 'processing');
      expect(repository.requests.single.amountPaise, 48950);
      await tester.ensureVisible(find.text('Record completed transfer'));
      await tester.tap(find.text('Record completed transfer'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Bank transfer reference (UTR)'),
        'UTR-123',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(
            FilledButton,
            'Record completed transfer',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.requests.single.status, 'paid');
      expect(find.textContaining('UTR-123'), findsOneWidget);
    },
  );
}
