import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/ui/core/legal.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';
import 'package:fieldnotes_flutter/ui/features/trust/account_deletion.dart';
import 'package:fieldnotes_flutter/ui/features/trust/trust_center_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _policies = LegalPolicies(
  privacyPolicyVersion: '2030-01-01',
  termsVersion: '2030-02-02',
  privacyPolicyUrl: 'https://example.test/legal/privacy',
  termsUrl: 'https://example.test/legal/terms',
  requiredConsents: allConsentKeys,
);

void main() {
  testWidgets('consent gate needs every required box and shows versions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final model = FieldnoteViewModel(FieldnoteRepository())
      ..legalPolicies = _policies;
    addTearDown(model.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LegalConsentGate(viewModel: model)),
    );

    FilledButton accept() => tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Accept and continue'),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton),
      ),
    );

    expect(find.textContaining('Terms v2030-02-02'), findsOneWidget);
    expect(find.textContaining('Policy v2030-01-01'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms'), findsOneWidget);
    expect(accept().onPressed, isNull);

    for (final key in allConsentKeys.take(2)) {
      await tester.tap(find.byKey(ValueKey('consent-$key')));
      await tester.pump();
      expect(accept().onPressed, isNull);
    }
    await tester.tap(find.byKey(ValueKey('consent-${allConsentKeys.last}')));
    await tester.pump();
    expect(accept().onPressed, isNotNull);

    // Unchecking one disables it again.
    await tester.tap(find.byKey(ValueKey('consent-${allConsentKeys.first}')));
    await tester.pump();
    expect(accept().onPressed, isNull);
  });

  test('required consents fall back to all three', () {
    expect(requiredConsentsGiven({consentLocation: true}, null), isFalse);
    expect(
      requiredConsentsGiven({
        for (final key in allConsentKeys) key: true,
      }, null),
      isTrue,
    );
    final onlyLocation = _policies.copyWith(
      requiredConsents: [consentLocation],
    );
    expect(
      requiredConsentsGiven({consentLocation: true}, onlyLocation),
      isTrue,
    );
  });

  test('consent is current only with all switches and current versions', () {
    final userId = UuidValue.withValidation(
      '550e8400-e29b-41d4-a716-446655440000',
    );
    final consent = LegalConsent(
      authUserId: userId,
      privacyPolicyVersion: 'p1',
      termsVersion: 't1',
      locationConsent: true,
      aiProcessingConsent: true,
      evidenceSharingConsent: true,
    );
    final trust = TrustCenterSummary(
      recentEvents: const [],
      privacyPolicyVersion: 'p1',
      termsVersion: 't1',
      locationProtection: '',
      moderationProtection: '',
      paymentProtection: '',
      retentionNotice: '',
    );
    expect(consentIsCurrent(consent, trust), isTrue);
    expect(
      consentIsCurrent(consent.copyWith(aiProcessingConsent: false), trust),
      isFalse,
    );
    expect(
      consentIsCurrent(consent, trust.copyWith(termsVersion: 't2')),
      isFalse,
    );
    expect(consentIsCurrent(null, trust), isFalse);
  });

  test('deletion status labels and in-flight states', () {
    expect(accountDeletionStatusLabel('pending'), 'Deletion pending');
    expect(accountDeletionStatusLabel('processing'), 'Deletion in progress');
    expect(accountDeletionStatusLabel('completed'), 'Account deleted');
    expect(accountDeletionStatusLabel('failed'), 'Deletion failed');
    final request = AccountDeletionRequest(
      authUserId: UuidValue.withValidation(
        '550e8400-e29b-41d4-a716-446655440000',
      ),
      status: 'processing',
    );
    expect(deletionInFlight(request), isTrue);
    expect(deletionInFlight(request.copyWith(status: 'failed')), isFalse);
    expect(deletionInFlight(null), isFalse);
  });
}
