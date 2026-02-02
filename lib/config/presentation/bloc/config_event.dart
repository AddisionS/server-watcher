abstract class ConfigEvent {}

class ConfigInitialLoad extends ConfigEvent {}

class SubmitThresholds extends ConfigEvent {
  final double subTemp, thresTemp, subHum, thresHum;
  SubmitThresholds({
    required this.subTemp,
    required this.thresTemp,
    required this.subHum,
    required this.thresHum,
  });
}

class SubmitContacts extends ConfigEvent {
  final String emailsString; // Raw string from text field
  final String phonesString; // Raw string from text field
  SubmitContacts({required this.emailsString, required this.phonesString});
}
