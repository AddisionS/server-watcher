import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/config_entities.dart';
import '../models/thresholds_model.dart'; // Import your model

// Define the Interface (matches what you already have)
abstract class ConfigRemoteDataSource {
  Future<ThresholdsEntity> fetchThresholds();
  Future<void> postThresholds(ThresholdsEntity data);
  // ... (Add contacts methods here later)
}

class ConfigRemoteDataSourceImpl implements ConfigRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;
  final String baseUrl = "http://127.0.0.1:8000";

  ConfigRemoteDataSourceImpl({
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
  Future<ThresholdsEntity> fetchThresholds() async {
    final url = Uri.parse('$baseUrl/admin/thresholds/');

    final response = await client.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      return ThresholdsModel.fromJson(jsonMap);
    } else {
      throw Exception('Failed to fetch thresholds: ${response.statusCode}');
    }
  }

  @override
  Future<void> postThresholds(ThresholdsEntity data) async {
    final url = Uri.parse('$baseUrl/admin/thresholds/');

    // Convert Entity -> Model -> JSON
    final model = ThresholdsModel(
      subTemp: data.subTemp,
      thresTemp: data.thresTemp,
      subHum: data.subHum,
      thresHum: data.thresHum,
    );

    final response = await client.put(
      url,
      headers: _getHeaders(),
      body: json.encode(model.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update thresholds: ${response.body}');
    }
  }
}
