import '../../domain/entities/user_item_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_datasource.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<UserItemEntity>> getUsers() => remoteDataSource.getUsers();

  @override
  Future<void> createUser(String username, String password, String role) =>
      remoteDataSource.createUser(username, password, role);

  @override
  Future<void> deleteUser(String username) =>
      remoteDataSource.deleteUser(username);
}
