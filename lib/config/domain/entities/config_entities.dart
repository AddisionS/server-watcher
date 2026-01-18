class ThresholdsEntity {
  final double minTemp;
  final double maxTemp;
  final double minHum;
  final double maxHum;

  ThresholdsEntity({
    required this.minTemp,
    required this.maxTemp,
    required this.minHum,
    required this.maxHum,
  });
}

class ContactEntity {
  final List<String> emails;
  final List<String> phoneNumbers;

  ContactEntity({required this.emails, required this.phoneNumbers});
}
