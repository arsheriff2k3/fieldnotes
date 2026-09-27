import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../generated/protocol.dart';

/// Server-side Groq fallback for FieldNote's text, image, and speech tasks.
class GroqAiService {
  GroqAiService({http.Client? client, this.endpoint = _defaultEndpoint})
    : _client = client ?? http.Client();

  static const _defaultEndpoint = 'https://api.groq.com/openai/v1';
  static const defaultVisionModel = 'qwen/qwen3.8-27b';
  static const defaultSpeechModel = 'whisper-large-v3-turbo';

  final http.Client _client;
  final String endpoint;

  Future<CampaignProposal> proposeCampaign({
    required String apiKey,
    required String prompt,
    required DateTime now,
    String model = defaultVisionModel,
  }) async {
    final json = await _chat(
      apiKey: apiKey,
      model: model,
      content: [
        {
          'type': 'text',
          'text':
              '''
Return only a JSON object for a safe, achievable local volunteer campaign.
Today is ${now.toUtc().toIso8601String()}. startsAt must be a future ISO-8601
date-time with timezone. Preserve an explicit budget and volunteer count.
Do not invent legal, medical, or environmental certainty.
Keep the sponsor's named city or place in locationName exactly as given. Do not
replace it with a nearby or more familiar place. The sponsor verifies the pin.
Required JSON keys: title, description, locationName, startsAt,
durationMinutes (30-720), volunteerCapacity (1-1000), fundingGoal (100-100000000),
requiredSkills (nonempty string array), checklist (at least two strings),
evidenceInstructions, tags (nonempty string array), rationale.

Sponsor request: ${prompt.trim()}
''',
        },
      ],
    );
    try {
      return CampaignProposal(
        title: _string(json, 'title'),
        description: _string(json, 'description'),
        locationName: _string(json, 'locationName'),
        startsAt: DateTime.parse(_string(json, 'startsAt')).toUtc(),
        durationMinutes: _int(json, 'durationMinutes', 30, 720),
        volunteerCapacity: _int(json, 'volunteerCapacity', 1, 1000),
        fundingGoal: _double(json, 'fundingGoal', 100, 100000000),
        requiredSkills: _list(json, 'requiredSkills'),
        checklist: _list(json, 'checklist'),
        evidenceInstructions: _string(json, 'evidenceInstructions'),
        tags: _list(json, 'tags'),
        rationale: _string(json, 'rationale'),
      );
    } on GroqAiException {
      rethrow;
    } catch (error) {
      throw GroqAiException('Groq campaign response was invalid.', error);
    }
  }

  Future<CompletionProposal> analyzeCompletion({
    required String apiKey,
    required String note,
    ByteData? photograph,
    String? photographMimeType,
    String model = defaultVisionModel,
  }) async {
    final content = <Map<String, Object?>>[
      {
        'type': 'text',
        'text':
            '''
Return only a JSON object describing work supported by the volunteer's note
and photograph. Never assert identity, fraud, legal compliance, or invisible
facts. Quantities must be in the note or clearly visible. The volunteer will
review this draft. Required JSON keys: summary, structuredResults (nonempty
string array), suggestedFollowUp, confidence (low, medium, or high), rationale.

Volunteer note: ${note.trim()}
''',
      },
      if (photograph != null && photographMimeType != null)
        {
          'type': 'image_url',
          'image_url': {
            'url':
                'data:$photographMimeType;base64,${base64Encode(
                  photograph.buffer.asUint8List(
                    photograph.offsetInBytes,
                    photograph.lengthInBytes,
                  ),
                )}',
          },
        },
    ];
    final json = await _chat(apiKey: apiKey, model: model, content: content);
    try {
      final confidenceName = _string(json, 'confidence').toLowerCase();
      return CompletionProposal(
        summary: _string(json, 'summary'),
        structuredResults: _list(json, 'structuredResults'),
        suggestedFollowUp: _string(json, 'suggestedFollowUp'),
        confidence: AiConfidence.values.firstWhere(
          (value) => value.name == confidenceName,
          orElse: () => AiConfidence.medium,
        ),
        rationale: _string(json, 'rationale'),
      );
    } on GroqAiException {
      rethrow;
    } catch (error) {
      throw GroqAiException('Groq evidence response was invalid.', error);
    }
  }

  Future<String> transcribe({
    required String apiKey,
    required ByteData audio,
    required String fileName,
    String model = defaultSpeechModel,
  }) async {
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('$endpoint/audio/transcriptions'),
    )
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..headers['User-Agent'] = 'FieldnotesServer/1.0'
      ..fields['model'] = model
          ..fields['response_format'] = 'json';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        audio.buffer.asUint8List(audio.offsetInBytes, audio.lengthInBytes),
        filename: fileName,
      ),
    );
    try {
      final response = await _client
          .send(request)
          .timeout(
            const Duration(seconds: 75),
          );
      final body = await response.stream.bytesToString();
      _checkStatus(response.statusCode, body);
      final json = jsonDecode(body);
      if (json is! Map ||
          json['text'] is! String ||
          (json['text'] as String).trim().isEmpty) {
        throw const GroqAiException('Groq returned no transcript.');
      }
      return (json['text'] as String).trim();
    } on GroqAiException {
      rethrow;
    } on Exception catch (error) {
      throw GroqAiException('Groq transcription failed.', error);
    }
  }

  Future<Map<String, dynamic>> _chat({
    required String apiKey,
    required String model,
    required List<Map<String, Object?>> content,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$endpoint/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'User-Agent': 'FieldnotesServer/1.0',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'user', 'content': content},
              ],
              'response_format': {'type': 'json_object'},
              'reasoning_effort': 'none',
              'temperature': 0.2,
              'max_completion_tokens': 512,
            }),
          )
          .timeout(const Duration(seconds: 60));
      _checkStatus(response.statusCode, response.body);
      final envelope = jsonDecode(response.body);
      final choices = envelope is Map ? envelope['choices'] : null;
      final first = choices is List && choices.isNotEmpty
          ? choices.first
          : null;
      final message = first is Map ? first['message'] : null;
      final raw = message is Map ? message['content'] : null;
      final json = raw is String ? jsonDecode(raw) : null;
      if (json is! Map<String, dynamic>) {
        throw const GroqAiException('Groq returned no JSON object.');
      }
      return json;
    } on GroqAiException {
      rethrow;
    } on Exception catch (error) {
      throw GroqAiException('Groq generation failed.', error);
    }
  }

  static void _checkStatus(int status, String body) {
    if (status >= 200 && status < 300) return;
    throw GroqAiException('Groq returned HTTP $status.', body, status);
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw GroqAiException('Groq omitted "$key".');
    }
    return value.trim();
  }

  static List<String> _list(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) throw GroqAiException('Groq omitted "$key".');
    final result = value
        .whereType<String>()
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList();
    if (result.isEmpty) throw GroqAiException('Groq omitted "$key".');
    return result;
  }

  static int _int(Map<String, dynamic> json, String key, int min, int max) {
    final value = json[key];
    if (value is! num) throw GroqAiException('Groq omitted "$key".');
    return value.round().clamp(min, max);
  }

  static double _double(
    Map<String, dynamic> json,
    String key,
    double min,
    double max,
  ) {
    final value = json[key];
    if (value is! num) throw GroqAiException('Groq omitted "$key".');
    return value.toDouble().clamp(min, max);
  }
}

class GroqAiException implements Exception {
  const GroqAiException(this.message, [this.cause, this.statusCode]);

  final String message;
  final Object? cause;
  final int? statusCode;

  bool get isQuotaExhausted => statusCode == 429;

  @override
  String toString() => 'GroqAiException: $message';
}
