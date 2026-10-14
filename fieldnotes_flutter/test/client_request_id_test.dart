import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/repositories/fieldnote_repository.dart';
import 'package:fieldnotes_flutter/data/services/client_request_id.dart';
import 'package:fieldnotes_flutter/data/services/device_time_zone_service.dart';
import 'package:fieldnotes_flutter/ui/features/shell/fieldnote_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _OrderRepository extends FieldnoteRepository {
  final requestIds = <String?>[];
  final List<Object> failures = [];

  @override
  Future<RazorpayCheckoutOrder> createRazorpayOrder(
    int campaignId,
    int amountPaise,
    String? message, {
    String? clientRequestId,
  }) async {
    requestIds.add(clientRequestId);
    if (failures.isNotEmpty) throw failures.removeAt(0);
    return RazorpayCheckoutOrder(
      sponsorshipId: requestIds.length,
      orderId: 'order_${requestIds.length}',
      keyId: 'rzp_test_x',
      amountPaise: amountPaise,
      currency: 'INR',
      campaignName: 'Tree planting',
      description: 'test',
    );
  }
}

void main() {
  group('ClientRequestIdTracker', () {
    test('reuses the id for the same request until it completes', () {
      var next = 0;
      final tracker = ClientRequestIdTracker(generate: () => 'id-${next++}');
      expect(tracker.idFor('draft-a'), 'id-0');
      expect(tracker.idFor('draft-a'), 'id-0', reason: 'retry');
      expect(tracker.idFor('draft-b'), 'id-1', reason: 'draft changed');
      tracker.complete();
      expect(tracker.idFor('draft-b'), 'id-2', reason: 'after success');
      tracker.discard();
      expect(tracker.current, isNull);
    });

    test('default ids are UUID v4 and accepted by the server format', () {
      final tracker = ClientRequestIdTracker();
      final id = tracker.idFor('x');
      expect(
        id,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(RegExp(r'^[A-Za-z0-9_.:\-]{8,64}$').hasMatch(id), isTrue);
    });
  });

  group('checkout idempotency', () {
    final campaign = Campaign(
      id: 7,
      organizationId: 1,
      name: 'Tree planting',
      description: 'Plant trees with local volunteers.',
      locationName: 'Pollachi',
      startsAt: DateTime.utc(2026, 10, 4),
      status: CampaignStatus.active,
      createdBy: UuidValue.withValidation(
        '550e8400-e29b-41d4-a716-446655440000',
      ),
    );

    test('a retry after a network error reuses the request id', () async {
      final repository = _OrderRepository()
        ..failures.add(const FormatException('connection dropped'));
      final model = FieldnoteViewModel(repository);
      await expectLater(
        model.createPaymentOrder(campaign, 50000, null),
        throwsFormatException,
      );
      await model.createPaymentOrder(campaign, 50000, null);
      expect(repository.requestIds, hasLength(2));
      expect(repository.requestIds[0], repository.requestIds[1]);

      // The order succeeded: the next checkout is a new attempt.
      await model.createPaymentOrder(campaign, 50000, null);
      expect(repository.requestIds[2], isNot(repository.requestIds[1]));

      // A different amount is a different request.
      await model.createPaymentOrder(campaign, 60000, null);
      expect(repository.requestIds[3], isNot(repository.requestIds[2]));
      model.dispose();
    });

    test('a rejected id is replaced on the next attempt', () async {
      final repository = _OrderRepository()
        ..failures.add(
          FieldnoteException(
            message: 'This payment request was already handled.',
            code: ClientRequestErrors.duplicatePayment,
          ),
        );
      final model = FieldnoteViewModel(repository);
      await expectLater(
        model.createPaymentOrder(campaign, 50000, 'Go team'),
        throwsA(isA<FieldnoteException>()),
      );
      await model.createPaymentOrder(campaign, 50000, 'Go team');
      expect(repository.requestIds[1], isNot(repository.requestIds[0]));
      model.dispose();
    });
  });

  group('device time zone', () {
    test('only IANA ids are sent', () {
      expect(validIanaTimeZone('Asia/Kolkata'), 'Asia/Kolkata');
      expect(
        validIanaTimeZone('America/Argentina/Buenos_Aires'),
        'America/Argentina/Buenos_Aires',
      );
      expect(validIanaTimeZone('UTC'), 'UTC');
      expect(validIanaTimeZone('IST'), isNull);
      expect(validIanaTimeZone('GMT+05:30'), isNull);
      expect(validIanaTimeZone('India Standard Time'), isNull);
      expect(validIanaTimeZone(''), isNull);
      expect(validIanaTimeZone(null), isNull);
    });

    test('a failing platform lookup falls back to null', () async {
      final service = DeviceTimeZoneService(
        lookup: () async => throw Exception('unsupported'),
      );
      expect(await service.ianaTimeZone(), isNull);
      final ok = DeviceTimeZoneService(lookup: () async => 'Asia/Kolkata');
      expect(await ok.ianaTimeZone(), 'Asia/Kolkata');
    });
  });
}
