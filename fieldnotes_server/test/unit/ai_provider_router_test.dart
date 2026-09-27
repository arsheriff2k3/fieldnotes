import 'package:fieldnotes_server/src/fieldnotes/services/ai_provider_router.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/gemini_ai_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/gemini_speech_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/groq_ai_service.dart';
import 'package:test/test.dart';

void main() {
  test('Gemini primary falls back to Groq on quota exhaustion', () async {
    final calls = <String>[];
    final result = await AiProviderRouter.run<String>(
      primary: AiProvider.gemini,
      gemini: () async {
        calls.add('gemini');
        throw const GeminiAiException('quota', null, 429);
      },
      groq: () async {
        calls.add('groq');
        return 'groq result';
      },
    );
    expect(result, 'groq result');
    expect(calls, ['gemini', 'groq']);
  });

  test('Groq primary falls back to Gemini on quota exhaustion', () async {
    final calls = <String>[];
    final result = await AiProviderRouter.run<String>(
      primary: AiProvider.groq,
      gemini: () async {
        calls.add('gemini');
        return 'gemini result';
      },
      groq: () async {
        calls.add('groq');
        throw const GroqAiException('quota', null, 429);
      },
    );
    expect(result, 'gemini result');
    expect(calls, ['groq', 'gemini']);
  });

  test('speech quota also triggers fallback', () async {
    final result = await AiProviderRouter.run<String>(
      primary: AiProvider.gemini,
      gemini: () async =>
          throw const SpeechTranscriptionException('quota', 429),
      groq: () async => 'transcript',
    );
    expect(result, 'transcript');
  });

  test('uses configured secondary when primary key is missing', () async {
    final result = await AiProviderRouter.run<String>(
      primary: AiProvider.groq,
      gemini: () async => 'gemini result',
    );
    expect(result, 'gemini result');
  });

  test('does not fail over for non-quota provider errors', () async {
    var groqCalled = false;
    await expectLater(
      AiProviderRouter.run<String>(
        primary: AiProvider.gemini,
        gemini: () async => throw const GeminiAiException('bad key', null, 401),
        groq: () async {
          groqCalled = true;
          return 'unexpected';
        },
      ),
      throwsA(isA<GeminiAiException>()),
    );
    expect(groqCalled, isFalse);
  });
}
