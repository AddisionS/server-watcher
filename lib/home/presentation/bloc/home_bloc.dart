import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/data_fetch_usecase.dart';
import '../../domain/entities/sensor_data_entity.dart';
import '../../../config/domain/usecases/get_thresholds_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetSensorStreamUseCase getSensorStreamUseCase;
  final GetThresholdsUseCase getThresholdsUseCase;

  StreamSubscription<SensorData>? sensorSubscription;

  HomeBloc({
    required this.getSensorStreamUseCase,
    required this.getThresholdsUseCase,
  }) : super(HomeLoading()) {
    // 1. Initial Load
    on<HomeInitialLoad>((event, emit) async {
      try {
        final thresholds = await getThresholdsUseCase.call();
        // Emit loaded with empty ID.
        // The UI (BlocListener in HomePage) will trigger the first device selection.
        emit(
          HomeLoaded(
            selectedDeviceId: "",
            sensorData: [],
            thresholds: thresholds,
          ),
        );
      } catch (e) {
        emit(HomeError("Failed to load thresholds"));
      }
    });

    // 2. Device Changed (UPDATED)
    on<HomeDeviceChanged>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;

        // Start polling the new Device ID
        subscribeToDevice(event.deviceId);

        emit(
          currentState.copyWith(
            selectedDeviceId: event.deviceId,
            sensorData: [], // Clear graph for new device
          ),
        );
      }
    });

    // 3. Data Arrived
    on<HomeDataUpdated>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        final updatedList = List<SensorData>.from(currentState.sensorData)
          ..add(event.data);

        if (updatedList.length > 20) updatedList.removeAt(0);

        emit(currentState.copyWith(sensorData: updatedList));
      }
    });
  }

  // Renamed helper function
  void subscribeToDevice(String deviceId) {
    sensorSubscription?.cancel();
    sensorSubscription = getSensorStreamUseCase
        .call(deviceId)
        .listen((data) => add(HomeDataUpdated(data)));
  }

  @override
  Future<void> close() {
    sensorSubscription?.cancel();
    return super.close();
  }
}
