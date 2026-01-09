import '../entities/user_entity.dart';

abstract class AuthRepository {
  // We want a function that takes a username and password.
  // It returns a Future because checking credentials takes time (async).
  // It returns a UserEntity if successful.
  Future<UserEntity> login(String username, String password);
  Future<UserEntity?> getLastLoggedInUser();
  Future<void> logout();
}
