import 'dart:convert'; // To convert String to Bytes
import 'dart:math';
import 'dart:typed_data';
import 'package:intl/intl.dart';

abstract class ExportRemoteDataSource {
  Future<Uint8List> fetchCsv(String room, DateTime start, DateTime end);
}

class ExportMockDataSourceImpl implements ExportRemoteDataSource {
  @override
  Future<Uint8List> fetchCsv(String room, DateTime start, DateTime end) async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Simulate Server processing

    // 1. Create CSV Header
    final buffer = StringBuffer();
    buffer.writeln("Timestamp,Room,Temperature,Humidity");

    // 2. Generate Fake Data between Start and End dates
    // Let's generate 1 row per hour to keep it simple
    DateTime current = start;
    final random = Random();

    while (current.isBefore(end)) {
      final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);
      final temp = (20 + random.nextDouble() * 10).toStringAsFixed(2);
      final hum = (40 + random.nextDouble() * 20).toStringAsFixed(2);

      buffer.writeln("$timeStr,$room,$temp,$hum");

      // Advance by 1 hour
      current = current.add(const Duration(hours: 1));
    }

    // 3. Convert String to Bytes (Uint8List)
    return utf8.encode(buffer.toString());
  }
}
