import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthDataSource {
  Future<UserModel> loginUser(String username, String password);
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> logout();
}

class AuthDataSourceImpl implements AuthDataSource {
  final SharedPreferences sharedPreferences;

  AuthDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel> loginUser(String username, String password) async {
    if (username == 'admin' && password == 'SDC@admin') {
      return UserModel(username: 'admin', role: 'admin');
    } else if (username == 'user' && password == 'SDC@user') {
      return UserModel(username: 'user', role: 'user');
    } else {
      throw Exception('Wrong username or password !!');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString('CACHED_USERNAME', user.username);
    await sharedPreferences.setString('CACHED_ROLE', user.role);
  }

  @override
  Future<UserModel?> getLastUser() async {
    // Try to get data
    final username = sharedPreferences.getString('CACHED_USERNAME');
    final role = sharedPreferences.getString('CACHED_ROLE');

    if (username != null && role != null) {
      return UserModel(username: username, role: role);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    // Clear the data
    await sharedPreferences.remove('CACHED_USERNAME');
    await sharedPreferences.remove('CACHED_ROLE');
  }
}
