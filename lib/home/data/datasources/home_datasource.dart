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
  Stream<SensorModel> getSensorStream(String deviceId) {
    // 1. Create a Controller
    late StreamController<SensorModel> controller;
    bool isActive = true; // The Kill Switch flag

    controller = StreamController<SensorModel>(
      onListen: () async {
        // Start the loop ONLY when someone listens
        while (isActive) {
          try {
            final url = Uri.parse('$baseUrl/metrics/latest/$deviceId');
            final response = await client.get(url, headers: _getHeaders());

            // Check flag again after await (Crucial!)
            if (!isActive) break;

            if (response.statusCode == 200) {
              final jsonMap = json.decode(response.body);
              final data = SensorModel.fromJson(jsonMap);
              controller.add(data); // Push data
            } else {
              print("Polling Error: ${response.statusCode}");
            }
          } catch (e) {
            print("Network Error: $e");
          }

          // Wait 2 seconds, but check flag periodically or after wait
          if (!isActive) break;
          await Future.delayed(const Duration(seconds: 2));
        }
        await controller.close();
      },
      onCancel: () {
        isActive = false;
      },
    );

    return controller.stream;
  }
}
