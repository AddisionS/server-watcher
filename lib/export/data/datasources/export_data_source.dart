import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app_config.dart';

abstract class ExportDataSource {
  Future<Uint8List> fetchCsv(String deviceId, DateTime start, DateTime end);
}

class ExportDataSourceImpl implements ExportDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  ExportDataSourceImpl(this.client, this.sharedPreferences);

  @override
  Future<Uint8List> fetchCsv(String deviceId, DateTime start, DateTime end) async {
    final token = sharedPreferences.getString('auth_token') ?? '';
    final uri = Uri.parse('${AppConfig.baseUrl}/export/$deviceId').replace(
      queryParameters: {
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
      },
    );
    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Export failed: ${response.statusCode}');
    }
    return response.bodyBytes;
  }
}
