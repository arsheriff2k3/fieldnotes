import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a revised policy sends an existing account through consent again', () {
    final model = FieldnoteViewModel(FieldnoteRepository());
    final userId = UuidValue.withValidation(
      '550e8400-e29b-41d4-a716-446655440000',
    );
    model.loading = false;
    model.profile = FieldnoteUserProfile(
      authUserId: userId,
      role: AccountRole.volunteer,
      displayName: 'Volunteer',
      city: 'Pune',
      interests: '',
      skills: '',
    );
    model.consent = LegalConsent(
      authUserId: userId,
      privacyPolicyVersion: 'old-policy',
      termsVersion: 'current-terms',
      locationConsent: true,
      aiProcessingConsent: true,
      evidenceSharingConsent: true,
    );
    model.trustCenter = TrustCenterSummary(
      recentEvents: const [],
      privacyPolicyVersion: 'current-policy',
      termsVersion: 'current-terms',
      locationProtection: '',
      moderationProtection: '',
      paymentProtection: '',
      retentionNotice: '',
    );

    expect(model.needsConsent, isTrue);
    model.consent = model.consent!.copyWith(
      privacyPolicyVersion: 'current-policy',
    );
    expect(model.needsConsent, isFalse);
    model.dispose();
  });
}
