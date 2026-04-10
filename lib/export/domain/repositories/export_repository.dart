import 'dart:typed_data'; // For Uint8List (Bytes)

abstract class ExportRepository {
  // Returns the file data (Bytes) and a suggested filename
  Future<Uint8List> generateCsvReport(
    String deviceId,
    DateTime start,
    DateTime end,
  );
}
