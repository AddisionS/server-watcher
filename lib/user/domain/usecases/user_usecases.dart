import '../entities/user_item_entity.dart';
import '../repositories/users_repository.dart';

class GetUsersUseCase {
  final UsersRepository repo;
  GetUsersUseCase(this.repo);
  Future<List<UserItemEntity>> call() => repo.getUsers();
}

class CreateUserUseCase {
  final UsersRepository repo;
  CreateUserUseCase(this.repo);
  Future<void> call(String username, String password, String role) =>
      repo.createUser(username, password, role);
}

class DeleteUserUseCase {
  final UsersRepository repo;
  DeleteUserUseCase(this.repo);
  Future<void> call(String username) => repo.deleteUser(username);
}
