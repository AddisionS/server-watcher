import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/domain/entities/config_entities.dart';
import '../../domain/usecases/room_fetch_usecase.dart';
import '../../domain/usecases/data_fetch_usecase.dart';
import '../../domain/entities/sensor_data_entity.dart';
import '../../domain/usecases/thresholds_fetch_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRoomsUseCase getRoomsUseCase;
  final GetSensorStreamUseCase getSensorStreamUseCase;
  final GetThresholdsUseCase getThresholdsUseCase;

  // We keep track of the active connection here
  StreamSubscription<SensorData>? sensorSubscription;

  HomeBloc({
    required this.getRoomsUseCase,
    required this.getSensorStreamUseCase,
    required this.getThresholdsUseCase,
  }) : super(HomeLoading()) {
    // 1. Initial Load
    on<HomeInitialLoad>((event, emit) async {
      emit(HomeLoading());
      try {
        final results = await Future.wait([
          getRoomsUseCase.call(),
          getThresholdsUseCase.call(),
        ]);

        final rooms = results[0] as List<String>;
        final thresholds = results[1] as ThresholdsEntity;

        if (rooms.isNotEmpty) {
          // Default to the first room
          final firstRoom = rooms.first;

          // Start the stream for the first room
          subscribeToRoom(firstRoom);

          // Emit initial success state with empty data (waiting for stream)
          emit(
            HomeLoaded(
              rooms: rooms,
              selectedRoom: firstRoom,
              sensorData: [],
              thresholds: thresholds,
            ),
          );
        } else {
          emit(HomeError("No rooms found"));
        }
      } catch (e) {
        emit(HomeError("Failed to load rooms"));
      }
    });

    // 2. User Changed Room
    on<HomeRoomChanged>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;

        // Start listening to the new room
        subscribeToRoom(event.room);

        // Update state: Change selectedRoom and Clear graph data
        emit(
          currentState.copyWith(
            selectedRoom: event.room,
            sensorData: [], // Clear old graph
          ),
        );
      }
    });

    // 3. New Data Arrived (Internal)
    on<HomeDataUpdated>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;

        // Create a new list with the new point added
        final updatedList = List<SensorData>.from(currentState.sensorData)
          ..add(event.data);

        // Optional: Keep only last 20 points to prevent memory overflow
        if (updatedList.length > 20) {
          updatedList.removeAt(0);
        }

        // Emit new state to redraw graph
        emit(currentState.copyWith(sensorData: updatedList));
      }
    });
  }

  // Helper function to manage the subscription
  void subscribeToRoom(String room) {
    // Cancel existing subscription if any
    sensorSubscription?.cancel();

    // Listen to the new stream
    sensorSubscription = getSensorStreamUseCase
        .call(room)
        .listen(
          (data) {
            // When data arrives, Add an Event to this BLoC
            add(HomeDataUpdated(data));
          },
          onError: (error) {
            // Handle stream errors if needed
          },
        );
  }

  // cleanup when BLoC is destroyed
  @override
  Future<void> close() {
    sensorSubscription?.cancel();
    return super.close();
  }
}
