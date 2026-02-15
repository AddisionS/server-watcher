import 'dart:typed_data';

class FirmwareResponse {
  final Uint8List bytes;
  final String filename;

  FirmwareResponse({required this.bytes, required this.filename});
}
