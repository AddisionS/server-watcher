import '../entities/user_item_entity.dart';

abstract class UsersRepository {
  Future<List<UserItemEntity>> getUsers();
  Future<void> createUser(String username, String password, String role);
  Future<void> deleteUser(String username);
}
