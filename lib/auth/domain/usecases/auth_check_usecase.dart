import '../entities/user_entity.dart';
import '../repositories/auth_repo.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<UserEntity?> call() async {
    return await repository.getLastLoggedInUser();
  }
}
