import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/config_entities.dart';
import '../models/thresholds_model.dart';
import '../../../app_config.dart';

// Define the Interface (matches what you already have)
abstract class ConfigRemoteDataSource {
  Future<ThresholdsEntity> fetchThresholds();
  Future<void> postThresholds(ThresholdsEntity data);
  Future<ContactEntity> fetchContacts();
  Future<void> addEmail(String email);
  Future<void> removeEmail(String email);
  Future<void> addPhone(String phone);
  Future<void> removePhone(String phone);
}

class ConfigRemoteDataSourceImpl implements ConfigRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

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
    final url = Uri.parse('${AppConfig.baseUrl}/admin/thresholds/');
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
    final url = Uri.parse('${AppConfig.baseUrl}/admin/thresholds/');

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

  @override
  Future<ContactEntity> fetchContacts() async {
    final emailUrl = Uri.parse('${AppConfig.baseUrl}/admin/alerts/emails');
    final phoneUrl = Uri.parse('${AppConfig.baseUrl}/admin/alerts/phones');

    final responses = await Future.wait([
      client.get(emailUrl, headers: _getHeaders()),
      client.get(phoneUrl, headers: _getHeaders()),
    ]);

    if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
      final emailData = json.decode(responses[0].body);
      final phoneData = json.decode(responses[1].body);
      return ContactEntity(
        emails: List<String>.from(emailData['emails'] ?? []),
        phoneNumbers: List<String>.from(phoneData['phones'] ?? []),
      );
    } else {
      throw Exception('Failed to fetch alert contacts');
    }
  }

  @override
  Future<void> addEmail(String email) async {
    // FastAPI expects: POST /admin/alerts/emails?email=test@test.com
    final url = Uri.parse(
      '${AppConfig.baseUrl}/admin/alerts/emails',
    ).replace(queryParameters: {'email': email});
    final response = await client.post(url, headers: _getHeaders());
    if (response.statusCode != 200) throw Exception('Failed to add email');
  }

  @override
  Future<void> removeEmail(String email) async {
    // FastAPI expects: DELETE /admin/alerts/emails?email=test@test.com
    final url = Uri.parse(
      '${AppConfig.baseUrl}/admin/alerts/emails',
    ).replace(queryParameters: {'email': email});
    final response = await client.delete(url, headers: _getHeaders());
    if (response.statusCode != 200) throw Exception('Failed to remove email');
  }

  @override
  Future<void> addPhone(String phone) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/admin/alerts/phones',
    ).replace(queryParameters: {'phone': phone});
    final response = await client.post(url, headers: _getHeaders());
    if (response.statusCode != 200) throw Exception('Failed to add phone');
  }

  @override
  Future<void> removePhone(String phone) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/admin/alerts/phones',
    ).replace(queryParameters: {'phone': phone});
    final response = await client.delete(url, headers: _getHeaders());
    if (response.statusCode != 200) throw Exception('Failed to remove phone');
  }
}
