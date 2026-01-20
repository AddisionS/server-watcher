import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/usecases/room_fetch_usecase.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final GetRoomsUseCase getRoomsUseCase;
  final GetAlertsUseCase getAlertsUseCase;

  AlertsBloc({required this.getRoomsUseCase, required this.getAlertsUseCase})
    : super(AlertsLoading()) {
    on<AlertsInitialLoad>((event, emit) async {
      emit(AlertsLoading());
      try {
        final rooms = await getRoomsUseCase.call();
        if (rooms.isNotEmpty) {
          final firstRoom = rooms.first;
          final alerts = await getAlertsUseCase.call(firstRoom);
          emit(
            AlertsLoaded(rooms: rooms, selectedRoom: firstRoom, alerts: alerts),
          );
        } else {
          emit(AlertsError("No rooms found"));
        }
      } catch (e) {
        emit(AlertsError("Failed to load alerts"));
      }
    });

    on<AlertsRoomChanged>((event, emit) async {
      if (state is AlertsLoaded) {
        final currentState = state as AlertsLoaded;
        emit(AlertsLoading()); // Show spinner while switching
        try {
          final alerts = await getAlertsUseCase.call(event.room);
          emit(currentState.copyWith(selectedRoom: event.room, alerts: alerts));
        } catch (e) {
          emit(AlertsError("Failed to load alerts for ${event.room}"));
        }
      }
    });
  }
}
