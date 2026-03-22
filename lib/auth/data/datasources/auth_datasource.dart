import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app_config.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> loginUser(String username, String password);
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> logout();
}

class AuthDataSourceImpl implements AuthDataSource {
  final http.Client client; // Inject HTTP Client
  final SharedPreferences sharedPreferences;
  AuthDataSourceImpl({required this.client, required this.sharedPreferences});

  @override
  Future<UserModel> loginUser(String username, String password) async {
    final url = Uri.parse('${AppConfig.baseUrl}/login');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        return UserModel.fromJson(jsonMap, username);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Credentials');
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString('CACHED_USERNAME', user.username);
    await sharedPreferences.setString('CACHED_ROLE', user.role);
    await sharedPreferences.setString('auth_token', user.token);
  }

  @override
  Future<UserModel?> getLastUser() async {
    final username = sharedPreferences.getString('CACHED_USERNAME');
    final role = sharedPreferences.getString('CACHED_ROLE');
    final token = sharedPreferences.getString('auth_token');

    if (username != null && role != null && token != null) {
      return UserModel(username: username, role: role, token: token);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove('CACHED_USERNAME');
    await sharedPreferences.remove('CACHED_ROLE');
    await sharedPreferences.remove('auth_token');
  }
}
