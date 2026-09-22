import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../generated/protocol.dart';

/// Gemini REST adapter for the two structured AI operations used by FieldNote.
///
/// The API key is supplied by Serverpod passwords and never reaches Flutter.
/// Every response is schema constrained and validated again while mapping it
/// into generated protocol models.
class GeminiAiService {
  const GeminiAiService({this.endpoint = _defaultEndpoint});

  static const _defaultEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final String endpoint;

  Future<CampaignProposal> proposeCampaign({
    required String apiKey,
    required String model,
    required String prompt,
    required DateTime now,
  }) async {
    final json = await _generate(
      apiKey: apiKey,
      model: model,
      parts: [
        {
          'text':
              '''
You are FieldNote's campaign planner. Convert the sponsor request into one
safe, achievable local volunteer campaign. Today is ${now.toUtc().toIso8601String()}.
Return a future ISO-8601 date-time. Preserve an explicit budget and volunteer
count when present. Do not invent legal, medical, or environmental certainty.

Sponsor request:
${prompt.trim()}
''',
        },
      ],
      schema: _campaignSchema,
    );
    return CampaignProposal(
      title: _requiredString(json, 'title'),
      description: _requiredString(json, 'description'),
      locationName: _requiredString(json, 'locationName'),
      startsAt: DateTime.parse(_requiredString(json, 'startsAt')).toUtc(),
      durationMinutes: _boundedInt(json, 'durationMinutes', 30, 720),
      volunteerCapacity: _boundedInt(json, 'volunteerCapacity', 1, 1000),
      fundingGoal: _boundedDouble(json, 'fundingGoal', 100, 100000000),
      requiredSkills: _stringList(json, 'requiredSkills'),
      checklist: _stringList(json, 'checklist'),
      evidenceInstructions: _requiredString(json, 'evidenceInstructions'),
      tags: _stringList(json, 'tags'),
      rationale: _requiredString(json, 'rationale'),
    );
  }

  Future<CompletionProposal> analyzeCompletion({
    required String apiKey,
    required String model,
    required String note,
    ByteData? photograph,
    String? photographMimeType,
  }) async {
    final parts = <Map<String, Object?>>[
      {
        'text':
            '''
You are FieldNote's evidence assistant. Structure only work supported by the
volunteer's note and photograph. Never claim fraud, identity, legal compliance,
or facts that are not visible. Quantities must come from the note or be clearly
visible. The volunteer will review and confirm this draft.

Volunteer note:
${note.trim()}
''',
      },
      if (photograph != null && photographMimeType != null)
        {
          'inlineData': {
            'mimeType': photographMimeType,
            'data': base64Encode(
              photograph.buffer.asUint8List(
                photograph.offsetInBytes,
                photograph.lengthInBytes,
              ),
            ),
          },
        },
    ];
    final json = await _generate(
      apiKey: apiKey,
      model: model,
      parts: parts,
      schema: _completionSchema,
    );
    final confidenceName = _requiredString(json, 'confidence').toLowerCase();
    final confidence = AiConfidence.values.firstWhere(
      (value) => value.name == confidenceName,
      orElse: () => AiConfidence.medium,
    );
    return CompletionProposal(
      summary: _requiredString(json, 'summary'),
      structuredResults: _stringList(json, 'structuredResults'),
      suggestedFollowUp: _requiredString(json, 'suggestedFollowUp'),
      confidence: confidence,
      rationale: _requiredString(json, 'rationale'),
    );
  }

  Future<Map<String, dynamic>> _generate({
    required String apiKey,
    required String model,
    required List<Map<String, Object?>> parts,
    required Map<String, Object?> schema,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final safeModel = Uri.encodeComponent(model.trim());
      final request = await client
          .postUrl(Uri.parse('$endpoint/$safeModel:generateContent'))
          .timeout(const Duration(seconds: 12));
      request.headers
        ..contentType = ContentType.json
        ..set('x-goog-api-key', apiKey.trim());
      request.write(
        jsonEncode({
          'contents': [
            {'role': 'user', 'parts': parts},
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': schema,
            'temperature': 0.2,
            'maxOutputTokens': 2048,
          },
        }),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 40),
      );
      final responseBody = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw GeminiAiException(
          'Gemini returned HTTP ${response.statusCode}: '
          '${_safeErrorMessage(responseBody)}',
        );
      }
      final envelope = jsonDecode(responseBody);
      if (envelope is! Map<String, dynamic>) {
        throw const GeminiAiException('Gemini returned an invalid response.');
      }
      final candidates = envelope['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        final feedback = envelope['promptFeedback'];
        throw GeminiAiException('Gemini returned no result. $feedback');
      }
      final first = candidates.first;
      final content = first is Map ? first['content'] : null;
      final returnedParts = content is Map ? content['parts'] : null;
      final firstPart = returnedParts is List && returnedParts.isNotEmpty
          ? returnedParts.first
          : null;
      final text = firstPart is Map ? firstPart['text'] : null;
      if (text is! String || text.trim().isEmpty) {
        throw const GeminiAiException('Gemini returned no structured text.');
      }
      final structured = jsonDecode(text);
      if (structured is! Map<String, dynamic>) {
        throw const GeminiAiException(
          'Gemini JSON did not match the expected object.',
        );
      }
      return structured;
    } on TimeoutException catch (error) {
      throw GeminiAiException('Gemini request timed out.', error);
    } on GeminiAiException {
      rethrow;
    } catch (error) {
      throw GeminiAiException('Gemini request failed.', error);
    } finally {
      client.close(force: true);
    }
  }

  static String _safeErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is Map) {
        final message = (decoded['error'] as Map)['message'];
        if (message is String) return message;
      }
    } catch (_) {}
    return 'The provider did not return a usable response.';
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw GeminiAiException('Gemini omitted required field "$key".');
    }
    return value.trim();
  }

  static List<String> _stringList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw GeminiAiException('Gemini omitted required list "$key".');
    }
    final result = value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (result.isEmpty) {
      throw GeminiAiException('Gemini returned an empty list for "$key".');
    }
    return result;
  }

  static int _boundedInt(
    Map<String, dynamic> json,
    String key,
    int minimum,
    int maximum,
  ) {
    final value = json[key];
    if (value is! num) throw GeminiAiException('Gemini omitted "$key".');
    return value.round().clamp(minimum, maximum);
  }

  static double _boundedDouble(
    Map<String, dynamic> json,
    String key,
    double minimum,
    double maximum,
  ) {
    final value = json[key];
    if (value is! num) throw GeminiAiException('Gemini omitted "$key".');
    return value.toDouble().clamp(minimum, maximum);
  }

  static const Map<String, Object?> _campaignSchema = {
    'type': 'object',
    'properties': {
      'title': {'type': 'string'},
      'description': {'type': 'string'},
      'locationName': {'type': 'string'},
      'startsAt': {
        'type': 'string',
        'format': 'date-time',
        'description': 'Future ISO-8601 date-time including timezone.',
      },
      'durationMinutes': {'type': 'integer', 'minimum': 30, 'maximum': 720},
      'volunteerCapacity': {'type': 'integer', 'minimum': 1, 'maximum': 1000},
      'fundingGoal': {'type': 'number', 'minimum': 100},
      'requiredSkills': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'checklist': {
        'type': 'array',
        'items': {'type': 'string'},
        'minItems': 2,
      },
      'evidenceInstructions': {'type': 'string'},
      'tags': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'rationale': {'type': 'string'},
    },
    'required': [
      'title',
      'description',
      'locationName',
      'startsAt',
      'durationMinutes',
      'volunteerCapacity',
      'fundingGoal',
      'requiredSkills',
      'checklist',
      'evidenceInstructions',
      'tags',
      'rationale',
    ],
  };

  static const Map<String, Object?> _completionSchema = {
    'type': 'object',
    'properties': {
      'summary': {
        'type': 'string',
        'description': 'Concise work summary grounded in the note and image.',
      },
      'structuredResults': {
        'type': 'array',
        'items': {'type': 'string'},
        'minItems': 1,
      },
      'suggestedFollowUp': {'type': 'string'},
      'confidence': {
        'type': 'string',
        'enum': ['low', 'medium', 'high'],
      },
      'rationale': {
        'type': 'string',
        'description':
            'Explain which visible or written details support the draft.',
      },
    },
    'required': [
      'summary',
      'structuredResults',
      'suggestedFollowUp',
      'confidence',
      'rationale',
    ],
  };
}

class GeminiAiException implements Exception {
  const GeminiAiException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'GeminiAiException: $message';
}
