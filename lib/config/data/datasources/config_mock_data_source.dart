import 'package:flutter/foundation.dart';

import '../../domain/entities/config_entities.dart';

abstract class ConfigRemoteDataSource {
  Future<void> postThresholds(ThresholdsEntity data);
  Future<void> postContacts(ContactEntity data);
  Future<ThresholdsEntity> fetchThresholds();
}

class ConfigMockDataSourceImpl implements ConfigRemoteDataSource {
  @override
  Future<void> postThresholds(ThresholdsEntity data) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate Network
    // In real app: http.post('api/config/thresholds', body: json...)
    debugPrint(
      "POSTED THRESHOLDS: Temp: ${data.subTemp}-${data.thresTemp}, Hum: ${data.subHum}-${data.thresHum}",
    );
  }

  @override
  Future<void> postContacts(ContactEntity data) async {
    await Future.delayed(const Duration(seconds: 2));
    // In real app: http.post('api/config/contacts', body: json...)
    debugPrint(
      "POSTED CONTACTS: Emails: ${data.emails}, Phones: ${data.phoneNumbers}",
    );
  }

  @override
  Future<ThresholdsEntity> fetchThresholds() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return ThresholdsEntity(
      subTemp: 20.0,
      thresTemp: 30.0,
      subHum: 60.0,
      thresHum: 80.0,
    );
  }
}
