import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app_config.dart';
import '../models/alert_model.dart';

abstract class AlertsRemoteDataSource {
  Future<List<AlertModel>> fetchAlerts({int limit = 100});
}

class AlertsRemoteDataSourceImpl implements AlertsRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  AlertsRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  Map<String, String> _getHeaders() {
    final token = sharedPreferences.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<AlertModel>> fetchAlerts({int limit = 100}) async {
    final url = Uri.parse('${AppConfig.baseUrl}/alerts/?limit=$limit');
    final response = await client.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => AlertModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch alerts: ${response.statusCode} ${response.body}',
      );
    }
  }
}
