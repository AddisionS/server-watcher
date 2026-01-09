import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repo.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<UserEntity> login(String username, String password) async {
    try {
      final userModel = await authDataSource.loginUser(username, password);
      await authDataSource.cacheUser(userModel);

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getLastLoggedInUser() async {
    return await authDataSource.getLastUser();
  }

  @override
  Future<void> logout() async {
    await authDataSource.logout();
  }
}
