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
      // Retry up to 3 times with a short delay to handle auth token race conditions
      // or transient server unavailability at startup.
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final thresholds = await getThresholdsUseCase.call();
          emit(
            HomeLoaded(
              selectedDeviceId: "",
              sensorData: [],
              thresholds: thresholds,
            ),
          );
          return;
        } catch (e) {
          if (attempt < 3) {
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }
      emit(HomeError("Failed to load thresholds"));
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

    on<HomeStopPolling>((event, emit) {
      sensorSubscription?.cancel(); // Kill the stream
      sensorSubscription = null;
      // Optional: Clear data from UI
      if (state is HomeLoaded) {
        final curr = state as HomeLoaded;
        emit(curr.copyWith(sensorData: []));
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
