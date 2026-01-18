abstract class ConfigState {}

class ConfigInitial extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigSuccess extends ConfigState {
  final String message; // "Thresholds Saved" or "Contacts Saved"
  ConfigSuccess(this.message);
}

class ConfigFailure extends ConfigState {
  final String error;
  ConfigFailure(this.error);
}
