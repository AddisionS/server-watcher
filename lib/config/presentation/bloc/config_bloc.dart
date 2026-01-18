import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/config_entities.dart';
import '../../domain/usecases/update_config_usecase.dart';
import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final UpdateThresholdsUseCase updateThresholdsUseCase;
  final UpdateContactsUseCase updateContactsUseCase;

  ConfigBloc({
    required this.updateThresholdsUseCase,
    required this.updateContactsUseCase,
  }) : super(ConfigInitial()) {
    // Handle Thresholds Submission
    on<SubmitThresholds>((event, emit) async {
      emit(ConfigLoading());
      try {
        final entity = ThresholdsEntity(
          subTemp: event.subTemp,
          thresTemp: event.thresTemp,
          subHum: event.subHum,
          thresHum: event.thresHum,
        );
        await updateThresholdsUseCase.call(entity);
        emit(ConfigSuccess("Thresholds updated successfully!"));
      } catch (e) {
        emit(ConfigFailure("Failed to update thresholds"));
      }
    });

    // Handle Contacts Submission
    on<SubmitContacts>((event, emit) async {
      emit(ConfigLoading());
      try {
        // Parse the comma-separated strings into Lists
        final emails = event.emailsString
            .split(',')
            .map((e) => e.trim())
            .toList();
        final phones = event.phonesString
            .split(',')
            .map((e) => e.trim())
            .toList();

        // Basic validation: remove empty strings
        emails.removeWhere((e) => e.isEmpty);
        phones.removeWhere((p) => p.isEmpty);

        final entity = ContactEntity(emails: emails, phoneNumbers: phones);
        await updateContactsUseCase.call(entity);

        emit(ConfigSuccess("Alert contacts updated successfully!"));
      } catch (e) {
        emit(ConfigFailure("Failed to update contacts"));
      }
    });
  }
}
