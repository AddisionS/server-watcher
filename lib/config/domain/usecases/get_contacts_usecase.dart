import '../entities/config_entities.dart';
import '../repositories/config_repository.dart';

class GetContactsUseCase {
  final ConfigRepository repository;

  GetContactsUseCase(this.repository);

  Future<ContactEntity> call() async {
    return await repository.getContacts();
  }
}
