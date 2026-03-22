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

// --- NEW CONTACT EVENTS ---
class AddEmailEvent extends ConfigEvent {
  final String email;
  AddEmailEvent(this.email);
}

class RemoveEmailEvent extends ConfigEvent {
  final String email;
  RemoveEmailEvent(this.email);
}

class AddPhoneEvent extends ConfigEvent {
  final String phone;
  AddPhoneEvent(this.phone);
}

class RemovePhoneEvent extends ConfigEvent {
  final String phone;
  RemovePhoneEvent(this.phone);
}
