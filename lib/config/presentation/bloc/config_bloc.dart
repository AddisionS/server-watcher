import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/config_entities.dart';
import '../../domain/usecases/update_config_usecase.dart';
import '../../domain/usecases/get_thresholds_usecase.dart';
import '../../domain/usecases/get_contacts_usecase.dart'; // IMPORT THIS
import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final UpdateThresholdsUseCase updateThresholdsUseCase;
  final GetThresholdsUseCase getThresholdsUseCase;

  // NEW USECASES
  final GetContactsUseCase getContactsUseCase;
  final AddEmailUseCase addEmailUseCase;
  final RemoveEmailUseCase removeEmailUseCase;
  final AddPhoneUseCase addPhoneUseCase;
  final RemovePhoneUseCase removePhoneUseCase;

  ConfigBloc({
    required this.updateThresholdsUseCase,
    required this.getThresholdsUseCase,
    required this.getContactsUseCase,
    required this.addEmailUseCase,
    required this.removeEmailUseCase,
    required this.addPhoneUseCase,
    required this.removePhoneUseCase,
  }) : super(ConfigInitial()) {
    // --- LOAD ALL DATA ---
    on<ConfigInitialLoad>((event, emit) async {
      emit(ConfigLoading());
      try {
        // Fetch both simultaneously for speed
        final results = await Future.wait([
          getThresholdsUseCase.call(),
          getContactsUseCase.call(),
        ]);
        emit(
          ConfigLoaded(
            thresholds: results[0] as ThresholdsEntity,
            contacts: results[1] as ContactEntity,
          ),
        );
      } catch (e) {
        emit(ConfigFailure("Failed to load configuration"));
      }
    });

    // --- THRESHOLDS ---
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
        add(ConfigInitialLoad()); // Reload everything
      } catch (e) {
        emit(ConfigFailure("Failed to update thresholds"));
        add(ConfigInitialLoad());
      }
    });

    // --- EMAILS ---
    on<AddEmailEvent>((event, emit) async {
      emit(ConfigLoading());
      try {
        await addEmailUseCase.call(event.email);
        emit(ConfigSuccess("Email added"));
        add(ConfigInitialLoad());
      } catch (e) {
        emit(ConfigFailure("Failed to add email"));
        add(ConfigInitialLoad());
      }
    });

    on<RemoveEmailEvent>((event, emit) async {
      emit(ConfigLoading());
      try {
        await removeEmailUseCase.call(event.email);
        emit(ConfigSuccess("Email removed"));
        add(ConfigInitialLoad());
      } catch (e) {
        emit(ConfigFailure("Failed to remove email"));
        add(ConfigInitialLoad());
      }
    });

    // --- PHONES ---
    on<AddPhoneEvent>((event, emit) async {
      emit(ConfigLoading());
      try {
        await addPhoneUseCase.call(event.phone);
        emit(ConfigSuccess("Phone number added"));
        add(ConfigInitialLoad());
      } catch (e) {
        emit(ConfigFailure("Failed to add phone"));
        add(ConfigInitialLoad());
      }
    });

    on<RemovePhoneEvent>((event, emit) async {
      emit(ConfigLoading());
      try {
        await removePhoneUseCase.call(event.phone);
        emit(ConfigSuccess("Phone number removed"));
        add(ConfigInitialLoad());
      } catch (e) {
        emit(ConfigFailure("Failed to remove phone"));
        add(ConfigInitialLoad());
      }
    });
  }
}
