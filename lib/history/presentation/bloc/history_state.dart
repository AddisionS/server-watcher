import '../../../home/domain/entities/sensor_data_entity.dart';

abstract class HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

class HistoryLoaded extends HistoryState {
  // REMOVED: final List<String> rooms;
  final String selectedDeviceId; // RENAMED
  final List<SensorData> historyData;

  HistoryLoaded({required this.selectedDeviceId, required this.historyData});

  HistoryLoaded copyWith({
    String? selectedDeviceId,
    List<SensorData>? historyData,
  }) {
    return HistoryLoaded(
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      historyData: historyData ?? this.historyData,
    );
  }
}
