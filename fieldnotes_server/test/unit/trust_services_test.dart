import 'package:fieldnotes_server/src/fieldnotes/services/content_moderation_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/location_integrity_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/razorpay_payment_service.dart';
import 'package:test/test.dart';

void main() {
  group('RazorpayPaymentService', () {
    const service = RazorpayPaymentService();

    test('verifies the checkout HMAC in constant-time comparison path', () {
      expect(
        service.verifySignature(
          orderId: 'order_test',
          paymentId: 'pay_test',
          signature:
              '05b0d688c1493b4a975fabdab67311036bb85932c2bd6804e5bc4a5c01db546d',
          keySecret: 'secret_test',
        ),
        isTrue,
      );
      expect(
        service.verifySignature(
          orderId: 'order_test',
          paymentId: 'pay_changed',
          signature:
              '05b0d688c1493b4a975fabdab67311036bb85932c2bd6804e5bc4a5c01db546d',
          keySecret: 'secret_test',
        ),
        isFalse,
      );
    });
  });

  group('LocationIntegrityService', () {
    const service = LocationIntegrityService();
    final now = DateTime.utc(2026, 9, 22, 10);

    test('accepts a fresh accurate live sample', () {
      final result = service.assess(
        latitude: 18.5204,
        longitude: 73.8567,
        accuracyMeters: 8,
        deviceReportedMock: false,
        explicitDemo: false,
        capturedAt: now.subtract(const Duration(seconds: 10)),
        now: now,
      );
      expect(result.allowed, isTrue);
      expect(result.status, 'verified');
    });

    test('rejects an unlabeled mock provider', () {
      final result = service.assess(
        latitude: 18.5204,
        longitude: 73.8567,
        accuracyMeters: 8,
        deviceReportedMock: true,
        explicitDemo: false,
        capturedAt: now,
        now: now,
      );
      expect(result.allowed, isFalse);
      expect(result.status, 'rejected');
      expect(result.reasons.join(' '), contains('mock location'));
    });

    test('allows explicit demo GPS but labels it demo', () {
      final result = service.assess(
        latitude: 18.5204,
        longitude: 73.8567,
        accuracyMeters: 8,
        deviceReportedMock: true,
        explicitDemo: true,
        capturedAt: now,
        now: now,
      );
      expect(result.allowed, isTrue);
      expect(result.status, 'demo');
    });
  });

  test('moderation blocks credible violence and exposed identifiers', () {
    const service = ContentModerationService();
    expect(service.evaluate('We cleared eight bags of waste.').allowed, isTrue);
    expect(
      service.evaluate('Plan to bomb a crowd near the school.').allowed,
      isFalse,
    );
    expect(
      service.evaluate('My card is 4111 1111 1111 1111').allowed,
      isFalse,
    );
  });
}
