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
    // 1. Initial Load: Now only fetches Thresholds.
    // It stays in Loading state until a room is actually changed/selected.
    on<HomeInitialLoad>((event, emit) async {
      try {
        final thresholds = await getThresholdsUseCase.call();
        // We emit a temporary Loaded state with no room selected yet
        // The UI/DevicesBloc will trigger the first RoomChange immediately
        emit(
          HomeLoaded(
            rooms: [], // This will be ignored as DevicesBloc handles the list
            selectedRoom: "",
            sensorData: [],
            thresholds: thresholds,
          ),
        );
      } catch (e) {
        emit(HomeError("Failed to load thresholds"));
      }
    });

    on<HomeRoomChanged>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        subscribeToRoom(event.room);
        emit(
          currentState.copyWith(
            selectedRoom: event.room,
            sensorData: [], // Clear graph for new room
          ),
        );
      }
    });

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

  void subscribeToRoom(String room) {
    sensorSubscription?.cancel();
    sensorSubscription = getSensorStreamUseCase
        .call(room)
        .listen((data) => add(HomeDataUpdated(data)));
  }

  @override
  Future<void> close() {
    sensorSubscription?.cancel();
    return super.close();
  }
}
