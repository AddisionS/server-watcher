import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_model.dart';

abstract class HomeRemoteDataSource {
  // We removed fetchRooms() as you requested
  Stream<SensorModel> getSensorStream(String deviceId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  // Use 10.0.2.2 for Android Emulator, localhost for Web
  final String baseUrl = "http://localhost:8000";

  HomeRemoteDataSourceImpl({
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
  Stream<SensorModel> getSensorStream(String deviceId) async* {
    // Continuous Polling Loop
    while (true) {
      try {
        final url = Uri.parse('$baseUrl/metrics/latest/$deviceId');

        final response = await client.get(url, headers: _getHeaders());

        if (response.statusCode == 200) {
          final jsonMap = json.decode(response.body);
          final data = SensorModel.fromJson(jsonMap);
          print("Received Sensor Data: $data");
          yield data;
        } else {
          // Optional: Log error or yield a specific error state
          // For now, we just ignore failed ticks to keep the stream alive
          print("Polling Error: ${response.statusCode}");
        }
      } catch (e) {
        print("Network Error during polling: $e");
      }

      // Wait 2 seconds before asking again
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
