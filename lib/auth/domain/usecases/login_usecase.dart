import '../entities/user_entity.dart';
import '../repositories/auth_repo.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String username, String password) async {
    return await repository.login(username, password);
  }
}
