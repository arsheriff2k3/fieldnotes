import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:fieldnotes_flutter/data/services/local_outbox_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Given a pending capture when stored then it survives a fresh read',
    () async {
      SharedPreferences.setMockInitialValues({});
      final service = LocalOutboxService();
      final capture = PendingCapture(
        input: ObservationInput(
          clientId: 'offline-1',
          campaignId: 7,
          assetId: 17,
          capturedAt: DateTime.utc(2026, 9, 22),
          latitude: 18.52,
          longitude: 73.85,
          accuracyMeters: 6,
          originalNote: 'Neem tree has dry soil.',
          species: 'Neem',
          condition: ObservationCondition.stressed,
          issues: ['Dry soil'],
          recommendedFollowUp: 'Watering',
          aiConfidence: AiConfidence.medium,
          aiRationale: 'Visible issue term in note.',
        ),
        imageBytes: Uint8List.fromList([1, 2, 3]),
        imageExtension: 'jpg',
      );

      await service.enqueue(capture);
      final loaded = await service.load();

      expect(loaded, hasLength(1));
      expect(loaded.single.input.clientId, 'offline-1');
      expect(loaded.single.input.issues, ['Dry soil']);
      expect(loaded.single.imageBytes, [1, 2, 3]);

      await service.remove('offline-1');
      expect(await service.load(), isEmpty);
    },
  );
}
