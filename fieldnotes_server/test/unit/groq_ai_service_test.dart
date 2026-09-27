import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fieldnotes_server/src/fieldnotes/services/gemini_ai_service.dart';
import 'package:fieldnotes_server/src/fieldnotes/services/groq_ai_service.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  test('Groq maps campaign and photo evidence and uploads dictation', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    final paths = <String>[];
    final chatRequests = <Map<String, dynamic>>[];
    final authHeaders = <String?>[];
    final userAgents = <String?>[];
    server.listen((request) async {
      paths.add(request.uri.path);
      authHeaders.add(request.headers.value('authorization'));
      userAgents.add(request.headers.value('user-agent'));
      final body = await request.fold<List<int>>(
        <int>[],
        (a, b) => a..addAll(b),
      );
      request.response.headers.contentType = ContentType.json;
      if (request.uri.path.endsWith('/audio/transcriptions')) {
        expect(request.headers.contentType?.mimeType, 'multipart/form-data');
        expect(
          utf8.decode(body, allowMalformed: true),
          contains('sample.webm'),
        );
        request.response.write(jsonEncode({'text': 'Cleaned the park.'}));
      } else {
        final parsed = jsonDecode(utf8.decode(body)) as Map<String, dynamic>;
        chatRequests.add(parsed);
        final result = chatRequests.length == 1
            ? {
                'title': 'Park Cleanup',
                'description': 'Clean the local park.',
                'locationName': 'Central Park',
                'startsAt': DateTime.now()
                    .toUtc()
                    .add(const Duration(days: 2))
                    .toIso8601String(),
                'durationMinutes': 120,
                'volunteerCapacity': 10,
                'fundingGoal': 10000,
                'requiredSkills': ['Outdoor work'],
                'checklist': ['Collect litter', 'Sort recycling'],
                'evidenceInstructions': 'Photograph cleaned area.',
                'tags': ['cleanup'],
                'rationale': 'Matches the sponsor request.',
              }
            : {
                'summary': 'Park area cleaned.',
                'structuredResults': ['Litter collected'],
                'suggestedFollowUp': 'Check tomorrow.',
                'confidence': 'high',
                'rationale': 'The note and photograph show the work.',
              };
        request.response.write(
          jsonEncode({
            'choices': [
              {
                'message': {'content': jsonEncode(result)},
              },
            ],
          }),
        );
      }
      await request.response.close();
    });

    final service = GroqAiService(
      endpoint: 'http://127.0.0.1:${server.port}/openai/v1',
    );
    final campaign = await service.proposeCampaign(
      apiKey: 'groq-test-key',
      prompt: 'Organize a local park cleanup with ten people.',
      now: DateTime.now(),
    );
    final evidence = await service.analyzeCompletion(
      apiKey: 'groq-test-key',
      note: 'We collected litter in the park.',
      photograph: ByteData.sublistView(Uint8List.fromList([1, 2, 3])),
      photographMimeType: 'image/jpeg',
    );
    final transcript = await service.transcribe(
      apiKey: 'groq-test-key',
      audio: ByteData.sublistView(Uint8List.fromList(List.filled(1800, 1))),
      fileName: 'sample.webm',
    );

    expect(paths, [
      '/openai/v1/chat/completions',
      '/openai/v1/chat/completions',
      '/openai/v1/audio/transcriptions',
    ]);
    expect(authHeaders, everyElement('Bearer groq-test-key'));
    expect(userAgents, everyElement('FieldnotesServer/1.0'));
    expect(chatRequests.first['model'], GroqAiService.defaultVisionModel);
    expect(campaign.title, 'Park Cleanup');
    final photoContent =
        (chatRequests.last['messages'] as List).first['content'] as List;
    expect(
      photoContent.last['image_url']['url'],
      'data:image/jpeg;base64,AQID',
    );
    expect(evidence.confidence, AiConfidence.high);
    expect(transcript, 'Cleaned the park.');
  });

  test('Gemini HTTP 429 is recognized as quota exhaustion', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    server.listen((request) async {
      await request.drain();
      request.response
        ..statusCode = 429
        ..write(
          jsonEncode({
            'error': {'message': 'Quota exceeded'},
          }),
        );
      await request.response.close();
    });
    final service = GeminiAiService(
      endpoint: 'http://127.0.0.1:${server.port}/v1beta/models',
    );
    await expectLater(
      service.proposeCampaign(
        apiKey: 'test',
        model: 'gemini-3.8-flash',
        prompt: 'A park cleanup',
        now: DateTime.now(),
      ),
      throwsA(
        isA<GeminiAiException>().having(
          (error) => error.isQuotaExhausted,
          'isQuotaExhausted',
          isTrue,
        ),
      ),
    );
  });
}
