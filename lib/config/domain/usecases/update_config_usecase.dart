import '../entities/config_entities.dart';
import '../repositories/config_repository.dart';

class UpdateThresholdsUseCase {
  final ConfigRepository repository;
  UpdateThresholdsUseCase(this.repository);

  Future<void> call(ThresholdsEntity data) async {
    return await repository.updateThresholds(data);
  }
}

class UpdateContactsUseCase {
  final ConfigRepository repository;
  UpdateContactsUseCase(this.repository);

  Future<void> call(ContactEntity data) async {
    return await repository.updateContacts(data);
  }
}
