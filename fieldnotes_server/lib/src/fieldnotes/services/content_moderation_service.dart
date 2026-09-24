class ModerationDecision {
  const ModerationDecision({
    required this.allowed,
    required this.categories,
  });

  final bool allowed;
  final List<String> categories;
}

/// Fast, deterministic first-pass moderation before content is stored.
///
/// Gemini still provides its provider safety filters for AI calls. This layer
/// keeps obviously unsafe text from being stored or sent to a provider and is
/// intentionally conservative and explainable.
class ContentModerationService {
  const ContentModerationService();

  static final Map<String, RegExp> _blocked = {
    'credible violence': RegExp(
      r'\b(kill|shoot|bomb|stab)\b.{0,30}\b(person|people|volunteer|crowd|school)\b',
      caseSensitive: false,
    ),
    'hate or dehumanization': RegExp(
      r'\b(exterminate|eradicate)\b.{0,30}\b(race|religion|caste|community)\b',
      caseSensitive: false,
    ),
    'illegal activity': RegExp(
      r'\b(buy|sell|make|distribute)\b.{0,25}\b(illegal drugs?|explosives?|weapons?)\b',
      caseSensitive: false,
    ),
    'personal data': RegExp(
      r'\b(?:\d[ -]*?){12,16}\b|\b[A-Z]{5}[0-9]{4}[A-Z]\b',
      caseSensitive: false,
    ),
  };

  ModerationDecision evaluate(String text) {
    final matches = <String>[];
    for (final entry in _blocked.entries) {
      if (entry.value.hasMatch(text)) matches.add(entry.key);
    }
    return ModerationDecision(allowed: matches.isEmpty, categories: matches);
  }
}
