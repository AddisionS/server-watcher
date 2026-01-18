class ThresholdsEntity {
  final double subTemp;
  final double thresTemp;
  final double subHum;
  final double thresHum;

  ThresholdsEntity({
    required this.subTemp,
    required this.thresTemp,
    required this.subHum,
    required this.thresHum,
  });
}

class ContactEntity {
  final List<String> emails;
  final List<String> phoneNumbers;

  ContactEntity({required this.emails, required this.phoneNumbers});
}
