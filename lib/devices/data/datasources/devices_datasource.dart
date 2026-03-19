import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';
import '../models/firmware_response.dart';
import '../../../app_config.dart';

abstract class DevicesRemoteDataSource {
  Future<List<DeviceModel>> getDevices();
  Future<FirmwareResponse> addDevice(String room); // Returns File Data
  Future<void> updateDevice(String id, String newRoom);
  Future<void> deleteDevice(String id);
}

class DevicesRemoteDataSourceImpl implements DevicesRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  DevicesRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  // Helper for Auth Headers
  Map<String, String> _getHeaders() {
    final token = sharedPreferences.getString('auth_token') ?? '';
    print(
      "Using Following credentials for request: \n token: $token\n role: ${sharedPreferences.getString('CACHED_ROLE')}",
    );
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<DeviceModel>> getDevices() async {
    final url = Uri.parse('${AppConfig.baseUrl}/admin/devices/');

    final response = await client.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> devicesList = jsonResponse['devices'];
      print("Devices fetched: $devicesList");

      return devicesList.map((json) => DeviceModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch devices: ${response.statusCode}');
    }
  }

  @override
  Future<FirmwareResponse> addDevice(String room) async {
    final url = Uri.parse('${AppConfig.baseUrl}/admin/devices/');

    final response = await client.post(
      url,
      headers: _getHeaders(),
      body: json.encode({"device_name": room}),
    );

    if (response.statusCode == 200) {
      // 1. Get the File Content (Bytes)
      final bytes = response.bodyBytes;

      // 2. Extract Filename from Header
      // Header format: 'attachment; filename="ESP-123.ino"'
      String filename = "firmware.ino"; // Default
      final contentDisposition = response.headers['content-disposition'];

      if (contentDisposition != null) {
        final match = RegExp(
          r'filename="?([^"]+)"?',
        ).firstMatch(contentDisposition);
        if (match != null && match.group(1) != null) {
          filename = match.group(1)!;
        }
      }

      return FirmwareResponse(bytes: bytes, filename: filename);
    } else if (response.statusCode == 409) {
      throw Exception('Device already exists or conflict');
    } else {
      throw Exception('Failed to add device: ${response.body}');
    }
  }

  @override
  Future<void> deleteDevice(String id) async {
    final url = Uri.parse('${AppConfig.baseUrl}/admin/devices/$id');
    final response = await client.delete(url, headers: _getHeaders());

    if (response.statusCode != 204) {
      throw Exception('Failed to delete device: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateDevice(String id, String newRoom) async {
    final url = Uri.parse('${AppConfig.baseUrl}/admin/devices/');

    final response = await client.put(
      url,
      headers: _getHeaders(),

      body: json.encode({"device_id": id, "device_name": newRoom}),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to update device: ${response.statusCode} ${response.body}',
      );
    }
  }
}
