import 'dart:typed_data';

class DeviceFileResult {
  final Uint8List fileBytes;
  final String fileName;

  DeviceFileResult({required this.fileBytes, required this.fileName});
}
