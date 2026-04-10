import 'dart:typed_data';
import 'package:http/http.dart' as http;

abstract class ExportDataSource {
  Future<Uint8List> fetchCsv(String deviceId, DateTime start, DateTime end);
}

class ExportDataSourceImpl implements ExportDataSource {
  final http.Client client;

  ExportDataSourceImpl(this.client);

  @override
  Future<Uint8List> fetchCsv(String deviceId, DateTime start, DateTime end) async {
    try {
      final uri = Uri.parse('/export/$deviceId').replace(queryParameters: {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      });
      final response = await client.get(uri);
      return response.bodyBytes;
    } catch (e) {
      // TODO: Handle error
      rethrow;
    }
  }
}
