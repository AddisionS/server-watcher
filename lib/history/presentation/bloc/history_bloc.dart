import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/usecases/room_fetch_usecase.dart'; // Reusing from Home
import '../../domain/usecases/get_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetRoomsUseCase getRoomsUseCase;
  final GetHistoryUseCase getHistoryUseCase;

  HistoryBloc({required this.getRoomsUseCase, required this.getHistoryUseCase})
    : super(HistoryLoading()) {
    // 1. Initial Load: Gets all Rooms -> Gets History for default room
    on<HistoryInitialLoad>((event, emit) async {
      emit(HistoryLoading());
      try {
        final rooms = await getRoomsUseCase.call();

        if (rooms.isNotEmpty) {
          final firstRoom = rooms.first;
          final history = await getHistoryUseCase.call(firstRoom);

          emit(
            HistoryLoaded(
              rooms: rooms,
              selectedRoom: firstRoom,
              historyData: history,
            ),
          );
        } else {
          emit(HistoryError("No rooms found"));
        }
      } catch (e) {
        emit(HistoryError("Failed to load data"));
      }
    });

    // 2. Room Changed: Keep rooms list, fetch new history
    on<HistoryRoomChanged>((event, emit) async {
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;

        // Show loading (optional: or keep showing old data with a spinner overlay)
        emit(HistoryLoading());

        try {
          final newHistory = await getHistoryUseCase.call(event.room);

          emit(
            currentState.copyWith(
              selectedRoom: event.room,
              historyData: newHistory,
            ),
          );
        } catch (e) {
          emit(HistoryError("Failed to fetch history for ${event.room}"));
        }
      }
    });
  }
}
