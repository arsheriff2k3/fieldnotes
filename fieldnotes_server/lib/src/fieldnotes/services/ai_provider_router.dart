import 'gemini_ai_service.dart';
import 'gemini_speech_service.dart';
import 'groq_ai_service.dart';

enum AiProvider { gemini, groq }

/// Runs the selected provider first, switching only for quota exhaustion.
class AiProviderRouter {
  const AiProviderRouter._();

  static Future<T> run<T>({
    required AiProvider primary,
    Future<T> Function()? gemini,
    Future<T> Function()? groq,
    void Function(AiProvider from, AiProvider to)? onFallback,
  }) async {
    if (gemini == null && groq == null) {
      throw StateError('At least one AI provider must be configured.');
    }
    final firstProvider = primary == AiProvider.gemini
        ? (gemini != null ? AiProvider.gemini : AiProvider.groq)
        : (groq != null ? AiProvider.groq : AiProvider.gemini);
    final first = firstProvider == AiProvider.gemini ? gemini! : groq!;
    final secondProvider = firstProvider == AiProvider.gemini
        ? AiProvider.groq
        : AiProvider.gemini;
    final second = firstProvider == AiProvider.gemini ? groq : gemini;

    try {
      return await first();
    } on GeminiAiException catch (error) {
      if (firstProvider != AiProvider.gemini ||
          !error.isQuotaExhausted ||
          second == null) {
        rethrow;
      }
    } on SpeechTranscriptionException catch (error) {
      if (firstProvider != AiProvider.gemini ||
          !error.isQuotaExhausted ||
          second == null) {
        rethrow;
      }
    } on GroqAiException catch (error) {
      if (firstProvider != AiProvider.groq ||
          !error.isQuotaExhausted ||
          second == null) {
        rethrow;
      }
    }
    onFallback?.call(firstProvider, secondProvider);
    return second();
  }
}
