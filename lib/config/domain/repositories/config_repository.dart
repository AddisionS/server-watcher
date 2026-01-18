import '../entities/config_entities.dart';

abstract class ConfigRepository {
  // Post Thresholds
  Future<void> updateThresholds(ThresholdsEntity thresholds);

  // Post Contacts
  Future<void> updateContacts(ContactEntity contacts);
}
