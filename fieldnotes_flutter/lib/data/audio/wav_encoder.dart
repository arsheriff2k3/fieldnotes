import 'dart:typed_data';

/// Wraps little-endian signed 16-bit PCM samples in a standard WAV container.
Uint8List encodePcm16Wav(
  Uint8List pcmBytes, {
  required int sampleRate,
  required int channels,
}) {
  if (sampleRate <= 0) throw ArgumentError.value(sampleRate, 'sampleRate');
  if (channels <= 0) throw ArgumentError.value(channels, 'channels');

  const headerLength = 44;
  const bitsPerSample = 16;
  final output = Uint8List(headerLength + pcmBytes.length);
  final header = ByteData.sublistView(output, 0, headerLength);

  _writeAscii(output, 0, 'RIFF');
  header.setUint32(4, 36 + pcmBytes.length, Endian.little);
  _writeAscii(output, 8, 'WAVE');
  _writeAscii(output, 12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(
    28,
    sampleRate * channels * bitsPerSample ~/ 8,
    Endian.little,
  );
  header.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
  header.setUint16(34, bitsPerSample, Endian.little);
  _writeAscii(output, 36, 'data');
  header.setUint32(40, pcmBytes.length, Endian.little);
  output.setRange(headerLength, output.length, pcmBytes);
  return output;
}

void _writeAscii(Uint8List target, int offset, String value) {
  for (var index = 0; index < value.length; index++) {
    target[offset + index] = value.codeUnitAt(index);
  }
}
