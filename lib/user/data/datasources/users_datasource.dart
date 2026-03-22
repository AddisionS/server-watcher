import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_item_model.dart';
import '../../../app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserItemModel>> getUsers();
  Future<void> createUser(String username, String password, String role);
  Future<void> deleteUser(String username);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final http.Client client; // This will be the AuthenticatedClient
  final SharedPreferences sharedPreferences;

  UsersRemoteDataSourceImpl({
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
  Future<List<UserItemModel>> getUsers() async {
    final url = Uri.parse('${AppConfig.baseUrl}/admin/users/');
    final response = await client.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => UserItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  @override
  Future<void> createUser(String username, String password, String role) async {
    final url = Uri.parse('${AppConfig.baseUrl}/admin/users/');
    final response = await client.post(
      url,
      headers: _getHeaders(),
      body: json.encode({
        "username": username,
        "password": password,
        "role": role,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // Extract the detail message from FastAPI if available
      String errorDetail = "Failed to create user";
      try {
        final errorBody = json.decode(response.body);
        if (errorBody['detail'] != null) {
          errorDetail = errorBody['detail'];
        }
      } catch (_) {}
      throw Exception(errorDetail);
    }
  }

  @override
  Future<void> deleteUser(String username) async {
    final url = Uri.parse('${AppConfig.baseUrl}/admin/users/$username');
    final response = await client.delete(url, headers: _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorDetail = "Failed to delete user";
      try {
        final errorBody = json.decode(response.body);
        if (errorBody['detail'] != null) {
          errorDetail = errorBody['detail'];
        }
      } catch (_) {}
      throw Exception(errorDetail);
    }
  }
}
