import '../entities/config_entities.dart';

abstract class ConfigRepository {
  // Post Thresholds
  Future<void> updateThresholds(ThresholdsEntity thresholds);
  Future<ThresholdsEntity> getThresholds();

  // Post Contacts
  Future<ContactEntity> getContacts();
  Future<void> addEmail(String email);
  Future<void> removeEmail(String email);
  Future<void> addPhone(String phone);
  Future<void> removePhone(String phone);
}
