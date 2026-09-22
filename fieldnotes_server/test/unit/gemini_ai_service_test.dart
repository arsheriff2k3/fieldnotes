import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fieldnotes_server/src/fieldnotes/services/gemini_ai_service.dart';
import 'package:fieldnotes_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  test('sends photo and note and maps Gemini structured evidence', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    Map<String, dynamic>? requestJson;
    String? apiKeyHeader;
    String? requestPath;
    server.listen((request) async {
      requestPath = request.uri.path;
      apiKeyHeader = request.headers.value('x-goog-api-key');
      requestJson = jsonDecode(await utf8.decoder.bind(request).join());
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode({
                        'summary': 'Six trees watered and waste removed.',
                        'structuredResults': [
                          '6 trees watered',
                          'Waste removed',
                        ],
                        'suggestedFollowUp': 'Inspect one damaged guard.',
                        'confidence': 'high',
                        'rationale':
                            'The note gives the count and the photograph shows the work area.',
                      }),
                    },
                  ],
                },
              },
            ],
          }),
        );
      await request.response.close();
    });

    final service = GeminiAiService(
      endpoint: 'http://127.0.0.1:${server.port}/v1beta/models',
    );
    final result = await service.analyzeCompletion(
      apiKey: 'test-key',
      model: 'gemini-3.8-flash',
      note: 'We watered 6 trees and cleared waste.',
      photograph: ByteData.sublistView(Uint8List.fromList([1, 2, 3, 4])),
      photographMimeType: 'image/jpeg',
    );

    expect(requestPath, '/v1beta/models/gemini-3.8-flash:generateContent');
    expect(apiKeyHeader, 'test-key');
    final parts = ((requestJson!['contents'] as List).first['parts'] as List);
    expect(parts, hasLength(2));
    expect(parts.last['inlineData']['mimeType'], 'image/jpeg');
    expect(parts.last['inlineData']['data'], base64Encode([1, 2, 3, 4]));
    expect(
      requestJson!['generationConfig']['responseMimeType'],
      'application/json',
    );
    expect(result.confidence, AiConfidence.high);
    expect(result.structuredResults, contains('6 trees watered'));
  });
}
