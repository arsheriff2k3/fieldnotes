import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class SpeechTranscriptionException implements Exception {
  const SpeechTranscriptionException(this.message);

  final String message;

  @override
  String toString() => 'SpeechTranscriptionException: $message';
}

/// Gemini Files + Interactions transcription adapter.
///
/// Audio is uploaded to the provider, transcribed, and the temporary provider
/// file is deleted in a finally block. The API key stays on the server, so the
/// Flutter app only ever sends raw audio bytes to this Serverpod endpoint.
class GeminiSpeechService {
  GeminiSpeechService({http.Client? client})
    : _client = client ?? http.Client();

  static const defaultModel = 'gemini-3.5-transcribe';

  final http.Client _client;

  Future<String> transcribe({
    required String apiKey,
    required String model,
    required ByteData audio,
    required String fileName,
    required String mimeType,
    String? language,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const SpeechTranscriptionException(
        'Speech transcription is not configured. Add geminiApiKey to Serverpod passwords.',
      );
    }
    final bytes = audio.buffer.asUint8List(
      audio.offsetInBytes,
      audio.lengthInBytes,
    );
    String? providerFileName;
    try {
      final start = await _client
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/upload/v1beta/files',
            ),
            headers: {
              'x-goog-api-key': apiKey,
              'X-Goog-Upload-Protocol': 'resumable',
              'X-Goog-Upload-Command': 'start',
              'X-Goog-Upload-Header-Content-Length': '${bytes.length}',
              'X-Goog-Upload-Header-Content-Type': mimeType,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'file': {'display_name': fileName},
            }),
          )
          .timeout(const Duration(seconds: 20));
      final uploadUrl = start.headers['x-goog-upload-url'];
      if (start.statusCode < 200 ||
          start.statusCode >= 300 ||
          uploadUrl == null) {
        throw SpeechTranscriptionException(
          'Gemini file upload initialization returned HTTP ${start.statusCode}.',
        );
      }
      final uploaded = await _client
          .post(
            Uri.parse(uploadUrl),
            headers: {
              'Content-Length': '${bytes.length}',
              'X-Goog-Upload-Offset': '0',
              'X-Goog-Upload-Command': 'upload, finalize',
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 45));
      if (uploaded.statusCode < 200 || uploaded.statusCode >= 300) {
        throw SpeechTranscriptionException(
          'Gemini file upload returned HTTP ${uploaded.statusCode}.',
        );
      }
      final fileBody = jsonDecode(uploaded.body);
      final file = fileBody is Map ? fileBody['file'] : null;
      final fileUri = file is Map ? file['uri'] : null;
      providerFileName = file is Map && file['name'] is String
          ? file['name'] as String
          : null;
      if (fileUri is! String) {
        throw const SpeechTranscriptionException(
          'Gemini file upload did not return a file URI.',
        );
      }
      final languageCodes = language == null || language.trim().isEmpty
          ? const <String>[]
          : <String>[language.trim()];
      final response = await _client
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/interactions',
            ),
            headers: {
              'x-goog-api-key': apiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'store': false,
              'input': [
                {'type': 'audio', 'uri': fileUri, 'mime_type': mimeType},
              ],
              'generation_config': {
                'transcription_config': {
                  'language_codes': languageCodes,
                  'mode': 'smart',
                },
              },
            }),
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == 404) {
          throw SpeechTranscriptionException(
            'Gemini transcription model "$model" was not found or is not available for this API key.',
          );
        }
        throw SpeechTranscriptionException(
          'Gemini transcription returned HTTP ${response.statusCode}.',
        );
      }
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw const SpeechTranscriptionException(
          'Gemini transcription returned invalid data.',
        );
      }
      final text = _interactionText(body);
      if (text == null || text.trim().isEmpty) {
        throw const SpeechTranscriptionException(
          'Gemini transcription returned an empty transcript.',
        );
      }
      return text.trim();
    } on SpeechTranscriptionException {
      rethrow;
    } on Exception catch (error) {
      throw SpeechTranscriptionException(
        'Gemini transcription request failed: ${error.runtimeType}.',
      );
    } finally {
      if (providerFileName != null) {
        try {
          await _client.delete(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/$providerFileName',
            ),
            headers: {'x-goog-api-key': apiKey},
          );
        } on Exception {
          // The temporary provider file expires automatically if cleanup fails.
        }
      }
    }
  }

  String? _interactionText(Map<String, dynamic> body) {
    final steps = body['steps'];
    if (steps is! List) return null;
    final values = <String>[];
    for (final step in steps.whereType<Map>()) {
      if (step['type'] != 'model_output') continue;
      final content = step['content'];
      if (content is! List) continue;
      for (final item in content.whereType<Map>()) {
        if (item['type'] == 'text' && item['text'] is String) {
          values.add(item['text'] as String);
        }
      }
    }
    return values.isEmpty ? null : values.join();
  }
}
