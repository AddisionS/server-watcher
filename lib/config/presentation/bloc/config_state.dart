import '../../domain/entities/config_entities.dart';

abstract class ConfigState {}

class ConfigInitial extends ConfigState {}

class ConfigLoading extends ConfigState {}

class ConfigLoaded extends ConfigState {
  final ThresholdsEntity thresholds;
  final ContactEntity contacts; // ADD THIS

  ConfigLoaded({required this.thresholds, required this.contacts});
}

class ConfigSuccess extends ConfigState {
  final String message;
  ConfigSuccess(this.message);
}

class ConfigFailure extends ConfigState {
  final String error;
  ConfigFailure(this.error);
}
