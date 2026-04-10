import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app_config.dart';
import '../../../../home/data/models/sensor_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<SensorModel>> fetchHistory(String deviceId);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  HistoryRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  // Helper for Auth Headers
  Map<String, String> _getHeaders() {
    final token = sharedPreferences.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<SensorModel>> fetchHistory(String deviceId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/metrics/24h/$deviceId');

    final response = await client.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => SensorModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch history data: ${response.statusCode} ${response.body}',
      );
    }
  }
}
