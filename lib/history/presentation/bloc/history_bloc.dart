import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  // REMOVED: GetRoomsUseCase
  final GetHistoryUseCase getHistoryUseCase;

  HistoryBloc({required this.getHistoryUseCase}) : super(HistoryLoading()) {
    // 1. Initial Load: Just set loading, wait for Device Selection
    on<HistoryInitialLoad>((event, emit) {
      emit(HistoryLoading());
    });

    // 2. Device Changed: Fetch History
    on<HistoryDeviceChanged>((event, emit) async {
      emit(HistoryLoading());
      try {
        final history = await getHistoryUseCase.call(event.deviceId);

        emit(
          HistoryLoaded(selectedDeviceId: event.deviceId, historyData: history),
        );
      } catch (e) {
        emit(HistoryError("Failed to fetch history for ${event.deviceId}"));
      }
    });
  }
}
