import 'package:fieldnotes_server/src/fieldnotes/services/structured_summary_service.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  const service = StructuredSummaryService();

  test('campaign proposal extracts sponsor budget and volunteer capacity', () {
    final proposal = service.proposeCampaign(
      'Plant trees at the university with 15 volunteers and ₹45000.',
      DateTime.utc(2026, 9, 22),
    );

    expect(proposal.title, 'Campus Tree Care Day');
    expect(proposal.locationName, 'University Campus');
    expect(proposal.volunteerCapacity, 15);
    expect(proposal.fundingGoal, 45000);
    expect(proposal.startsAt.weekday, DateTime.saturday);
    expect(proposal.checklist, isNotEmpty);
  });

  test('completion analysis keeps the volunteer as final confirmer', () {
    final result = service.analyzeCompletion(
      'We watered 12 trees, repaired 4 guards, and cleared 8 bags of plastic waste.',
    );

    expect(result.structuredResults, contains('12 trees watered'));
    expect(result.structuredResults, contains('4 guards repaired'));
    expect(result.structuredResults, contains('8 bags of waste cleared'));
    expect(result.confidence, AiConfidence.high);
    expect(result.rationale, contains('Volunteer confirmation is required'));
  });
}
