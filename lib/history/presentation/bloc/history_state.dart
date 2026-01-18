import '../../../../home/domain/entities/sensor_data_entity.dart';

// Holds historyData
abstract class HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

class HistoryLoaded extends HistoryState {
  final List<String> rooms; // For the Dropdown
  final String selectedRoom; // Currently selected
  final List<SensorData> historyData; // The 24h Log

  HistoryLoaded({
    required this.rooms,
    required this.selectedRoom,
    required this.historyData,
  });

  // CopyWith pattern for easy updates
  HistoryLoaded copyWith({
    List<String>? rooms,
    String? selectedRoom,
    List<SensorData>? historyData,
  }) {
    return HistoryLoaded(
      rooms: rooms ?? this.rooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      historyData: historyData ?? this.historyData,
    );
  }
}
