import '../../generated/protocol.dart';

/// A deterministic extraction service used by the MVP.
///
/// It deliberately produces suggestions, never diagnoses. The implementation
/// can be replaced by a hosted multimodal model without changing the endpoint
/// or client contract.
class ObservationAiService {
  const ObservationAiService();

  ObservationProposal analyze(String note) {
    final normalized = note.toLowerCase();
    final issues = <String>[];

    void addIssue(List<String> terms, String label) {
      if (terms.any(normalized.contains)) issues.add(label);
    }

    addIssue(['yellow', 'yellowing'], 'Yellow leaves');
    addIssue(['dry soil', 'soil is dry', 'needs water'], 'Dry soil');
    addIssue(['broken guard', 'guard is broken'], 'Broken guard');
    addIssue(['wilt', 'drooping'], 'Wilting');
    addIssue(['obstruct', 'blocked'], 'Obstruction');
    addIssue(['damage', 'snapped', 'broken branch'], 'Physical damage');
    addIssue(['missing', 'not found', 'no tree'], 'Tree not found');
    addIssue(['dead', 'no leaves', 'dried out'], 'Possible mortality');

    final species = _species(normalized);
    final condition = _condition(normalized, issues);
    final followUp = _followUp(normalized, condition, issues);
    final signals = issues.length + (species == null ? 0 : 1);
    final confidence = signals >= 4
        ? AiConfidence.high
        : signals >= 2
        ? AiConfidence.medium
        : AiConfidence.low;

    return ObservationProposal(
      species: species,
      condition: condition,
      issues: issues,
      recommendedFollowUp: followUp,
      confidence: confidence,
      rationale: issues.isEmpty
          ? 'The note contains limited visible-condition evidence. Confirm all fields.'
          : 'Suggested from ${issues.join(', ').toLowerCase()} in the volunteer note. Human confirmation is required.',
    );
  }

  String? _species(String note) {
    const species = {
      'neem': 'Neem',
      'mango': 'Mango',
      'peepal': 'Peepal',
      'banyan': 'Banyan',
      'jamun': 'Jamun',
      'gulmohar': 'Gulmohar',
    };
    for (final entry in species.entries) {
      if (note.contains(entry.key)) return entry.value;
    }
    return null;
  }

  ObservationCondition _condition(String note, List<String> issues) {
    if (note.contains('missing') || note.contains('not found')) {
      return ObservationCondition.missing;
    }
    if (note.contains('dead') || note.contains('no leaves')) {
      return ObservationCondition.dead;
    }
    if (note.contains('snapped') || note.contains('severely damaged')) {
      return ObservationCondition.damaged;
    }
    if (issues.isNotEmpty || note.contains('stressed')) {
      return ObservationCondition.stressed;
    }
    if (note.contains('healthy') || note.contains('good condition')) {
      return ObservationCondition.healthy;
    }
    return ObservationCondition.uncertain;
  }

  String _followUp(
    String note,
    ObservationCondition condition,
    List<String> issues,
  ) {
    final actions = <String>[];
    if (note.contains('water') || issues.contains('Dry soil')) {
      actions.add('Watering');
    }
    if (issues.contains('Broken guard')) actions.add('Guard repair');
    if (issues.contains('Obstruction')) actions.add('Clear obstruction');
    if (condition == ObservationCondition.dead ||
        condition == ObservationCondition.missing) {
      actions.add('Coordinator site check');
    }
    if (actions.isEmpty && condition == ObservationCondition.healthy) {
      return 'Routine monitoring';
    }
    return actions.isEmpty ? 'Human review' : actions.join(' and ');
  }
}
