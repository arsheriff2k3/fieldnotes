import '../../generated/protocol.dart';
import 'money.dart';

/// Deterministic helper for provider-independent impact summaries and tests.
///
/// The service exposes the same structured contracts a hosted language and
/// vision model would use, keeping pure summary logic independently testable.
class StructuredSummaryService {
  const StructuredSummaryService();

  CampaignProposal proposeCampaign(String prompt, DateTime now) {
    final text = prompt.toLowerCase();
    final treeCare = text.contains('tree') || text.contains('plant');
    final cleanup = text.contains('clean') || text.contains('waste');
    final volunteerMatch = RegExp(
      r'(\d+)\s*(?:volunteer|people|person)',
    ).firstMatch(text);
    final moneyMatch = RegExp(
      r'(?:₹|rs\.?|inr)?\s*([0-9][0-9,]{2,})',
    ).firstMatch(text);
    final capacity = int.tryParse(volunteerMatch?.group(1) ?? '') ?? 10;
    final amount =
        double.tryParse(
          (moneyMatch?.group(1) ?? '').replaceAll(',', ''),
        ) ??
        (treeCare ? 25000 : 15000);
    final nextSaturday = _nextWeekday(now, DateTime.saturday).copyWith(
      hour: 8,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    final title = treeCare
        ? 'Campus Tree Care Day'
        : cleanup
        ? 'Neighbourhood Cleanup Sprint'
        : 'Community Action Day';
    final tags = treeCare
        ? ['tree care', 'environment', 'outdoors']
        : cleanup
        ? ['cleanup', 'environment', 'community']
        : ['community', 'local impact'];
    final checklist = treeCare
        ? [
            'Water registered trees',
            'Inspect and repair support guards',
            'Clear waste around planting areas',
          ]
        : cleanup
        ? [
            'Collect and separate visible waste',
            'Photograph the cleaned area',
            'Record the number of filled bags',
          ]
        : [
            'Check in at the activity location',
            'Complete the published work',
            'Submit a photograph and short note',
          ];

    return CampaignProposal(
      title: title,
      description:
          'A sponsor-backed local action campaign generated from: “${prompt.trim()}”',
      locationName: text.contains('university')
          ? 'University Campus'
          : 'Campaign location',
      startsAt: nextSaturday.toUtc(),
      durationMinutes: 180,
      volunteerCapacity: capacity.clamp(2, 100).toInt(),
      fundingGoal: amount.clamp(1000, 10000000).toDouble(),
      fundingGoalPaise: Money.toPaise(amount.clamp(1000, 10000000).toDouble()),
      requiredSkills: treeCare
          ? ['No specialist skills', 'Comfortable working outdoors']
          : ['No specialist skills'],
      checklist: checklist,
      evidenceInstructions:
          'Submit one location-verified photograph and describe the completed work.',
      tags: tags,
      rationale:
          'The proposal extracts the cause, budget, volunteer requirement, place, and schedule from the sponsor’s request. Confirm every field before publishing.',
    );
  }

  CompletionProposal analyzeCompletion(String note) {
    final normalized = note.toLowerCase();
    final results = <String>[];

    final watered = _quantityBefore(normalized, 'tree');
    if (normalized.contains('water')) {
      results.add(
        watered == null ? 'Trees watered' : '$watered trees watered',
      );
    }
    final guards = _quantityBefore(normalized, 'guard');
    if (normalized.contains('guard')) {
      results.add(
        guards == null ? 'Tree guards repaired' : '$guards guards repaired',
      );
    }
    final bags = _quantityBefore(normalized, 'bag');
    if (normalized.contains('waste') || normalized.contains('plastic')) {
      results.add(
        bags == null ? 'Waste cleared' : '$bags bags of waste cleared',
      );
    }
    if (normalized.contains('plant')) results.add('Planting work completed');
    if (results.isEmpty) results.add('Campaign activity completed');

    final followUp =
        normalized.contains('damage') ||
            normalized.contains('broken') ||
            normalized.contains('follow')
        ? 'Sponsor should review the flagged maintenance issue.'
        : 'No immediate follow-up was identified from the note.';

    return CompletionProposal(
      summary: results.join(', '),
      structuredResults: results,
      suggestedFollowUp: followUp,
      confidence: results.length >= 2 ? AiConfidence.high : AiConfidence.medium,
      rationale:
          'Structured from quantities and completed actions in the volunteer’s original note. Volunteer confirmation is required.',
    );
  }

  /// Prefix of [CompletionProposal.rationale] for the non-AI fallback, so the
  /// client can tell it apart from a hosted model proposal.
  static const manualRationale =
      'AI analysis is unavailable. This summary was taken from your note';

  /// P0-8: a provider-free completion proposal built only from the
  /// volunteer's own note. The volunteer reviews and edits it before
  /// submitting, and the resulting evidence is recorded as not AI generated.
  CompletionProposal manualCompletionProposal(String note) {
    final cleaned = note.trim().replaceAll(RegExp(r'\s+'), ' ');
    final sentences = cleaned
        .split(RegExp(r'(?<=[.!?])\s+|\n+|;\s*'))
        .map((value) => value.trim().replaceAll(RegExp(r'[.!?]+$'), ''))
        .where((value) => value.length >= 3)
        .take(5)
        .toList();
    final summary = cleaned.length <= 280
        ? cleaned
        : '${cleaned.substring(0, 277).trimRight()}...';
    return CompletionProposal(
      summary: summary,
      structuredResults: sentences.isEmpty ? [summary] : sentences,
      suggestedFollowUp: '',
      confidence: AiConfidence.low,
      rationale: '$manualRationale. Review it before submitting.',
    );
  }

  String impactSummary({
    required int completedVolunteers,
    required List<CompletionEvidence> evidence,
  }) {
    if (completedVolunteers == 0) {
      return 'The campaign is ready for matched volunteers. Completed evidence will appear here.';
    }
    final results = evidence
        .map((item) => item.structuredResults.trim())
        .where((value) => value.isNotEmpty)
        .take(3)
        .join('; ');
    return '$completedVolunteers volunteer${completedVolunteers == 1 ? '' : 's'} completed verified campaign work${results.isEmpty ? '.' : ': $results.'}';
  }

  static DateTime _nextWeekday(DateTime from, int weekday) {
    var days = (weekday - from.weekday) % 7;
    if (days == 0) days = 7;
    return from.add(Duration(days: days));
  }

  static int? _quantityBefore(String text, String word) {
    final match = RegExp('(\\d+)\\s+$word').firstMatch(text);
    return int.tryParse(match?.group(1) ?? '');
  }
}
