import '../entities/config_entities.dart';
import '../repositories/config_repository.dart';

class UpdateThresholdsUseCase {
  final ConfigRepository repository;
  UpdateThresholdsUseCase(this.repository);
  Future<void> call(ThresholdsEntity data) async =>
      await repository.updateThresholds(data);
}

class AddEmailUseCase {
  final ConfigRepository repository;
  AddEmailUseCase(this.repository);
  Future<void> call(String email) async => await repository.addEmail(email);
}

class RemoveEmailUseCase {
  final ConfigRepository repository;
  RemoveEmailUseCase(this.repository);
  Future<void> call(String email) async => await repository.removeEmail(email);
}

class AddPhoneUseCase {
  final ConfigRepository repository;
  AddPhoneUseCase(this.repository);
  Future<void> call(String phone) async => await repository.addPhone(phone);
}

class RemovePhoneUseCase {
  final ConfigRepository repository;
  RemovePhoneUseCase(this.repository);
  Future<void> call(String phone) async => await repository.removePhone(phone);
}
