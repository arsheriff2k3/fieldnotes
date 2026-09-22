import 'package:fieldnotes_server/src/fieldnotes/services/observation_ai.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  const service = ObservationAiService();

  test(
    'Given a detailed stressed-tree note when analyzed then returns editable structured suggestions',
    () {
      final result = service.analyze(
        'Neem tree has yellow leaves, a broken guard, and dry soil. It needs watering.',
      );

      expect(result.species, 'Neem');
      expect(result.condition, ObservationCondition.stressed);
      expect(
        result.issues,
        containsAll(['Yellow leaves', 'Broken guard', 'Dry soil']),
      );
      expect(result.recommendedFollowUp, contains('Watering'));
      expect(result.confidence, AiConfidence.high);
    },
  );

  test(
    'Given an ambiguous note when analyzed then avoids claiming a diagnosis',
    () {
      final result = service.analyze('Tree photographed near the path.');

      expect(result.condition, ObservationCondition.uncertain);
      expect(result.confidence, AiConfidence.low);
      expect(result.rationale, contains('limited'));
    },
  );
}
