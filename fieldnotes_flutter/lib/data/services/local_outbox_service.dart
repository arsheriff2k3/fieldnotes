import 'dart:convert';
import 'dart:typed_data';

import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingCapture {
  const PendingCapture({
    required this.input,
    this.imageBytes,
    this.imageExtension,
  });

  final ObservationInput input;
  final Uint8List? imageBytes;
  final String? imageExtension;

  Map<String, dynamic> toJson() => {
    'input': input.toJson(),
    if (imageBytes != null) 'image': base64Encode(imageBytes!),
    if (imageExtension != null) 'extension': imageExtension,
  };

  factory PendingCapture.fromJson(Map<String, dynamic> json) {
    return PendingCapture(
      input: ObservationInput.fromJson(
        Map<String, dynamic>.from(json['input'] as Map),
      ),
      imageBytes: json['image'] == null
          ? null
          : base64Decode(json['image'] as String),
      imageExtension: json['extension'] as String?,
    );
  }
}

class LocalOutboxService {
  static const _key = 'fieldnote.capture.outbox.v1';

  Future<List<PendingCapture>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_key) ?? const [];
    return raw
        .map(
          (value) => PendingCapture.fromJson(
            Map<String, dynamic>.from(jsonDecode(value) as Map),
          ),
        )
        .toList();
  }

  Future<void> enqueue(PendingCapture capture) async {
    final items = await load();
    final index = items.indexWhere(
      (item) => item.input.clientId == capture.input.clientId,
    );
    if (index == -1) {
      items.add(capture);
    } else {
      items[index] = capture;
    }
    await _save(items);
  }

  Future<void> remove(String clientId) async {
    final items = await load();
    items.removeWhere((item) => item.input.clientId == clientId);
    await _save(items);
  }

  Future<void> _save(List<PendingCapture> items) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}
