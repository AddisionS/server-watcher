import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  // REMOVED: GetRoomsUseCase
  final GetAlertsUseCase getAlertsUseCase;

  AlertsBloc({required this.getAlertsUseCase}) : super(AlertsLoading()) {
    on<AlertsInitialLoad>((event, emit) {
      emit(AlertsLoading());
    });

    on<AlertsDeviceChanged>((event, emit) async {
      emit(AlertsLoading());
      try {
        final alerts = await getAlertsUseCase.call(event.deviceId);
        emit(AlertsLoaded(selectedDeviceId: event.deviceId, alerts: alerts));
      } catch (e) {
        emit(AlertsError("Failed to load alerts for ${event.deviceId}"));
      }
    });
  }
}
