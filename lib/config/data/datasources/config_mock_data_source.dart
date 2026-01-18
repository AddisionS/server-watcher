import '../../domain/entities/config_entities.dart';

abstract class ConfigRemoteDataSource {
  Future<void> postThresholds(ThresholdsEntity data);
  Future<void> postContacts(ContactEntity data);
}

class ConfigMockDataSourceImpl implements ConfigRemoteDataSource {
  @override
  Future<void> postThresholds(ThresholdsEntity data) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate Network
    // In real app: http.post('api/config/thresholds', body: json...)
    print(
      "POSTED THRESHOLDS: Temp: ${data.subTemp}-${data.thresTemp}, Hum: ${data.subHum}-${data.thresHum}",
    );
  }

  @override
  Future<void> postContacts(ContactEntity data) async {
    await Future.delayed(const Duration(seconds: 2));
    // In real app: http.post('api/config/contacts', body: json...)
    print(
      "POSTED CONTACTS: Emails: ${data.emails}, Phones: ${data.phoneNumbers}",
    );
  }
}
