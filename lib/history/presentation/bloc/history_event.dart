abstract class HistoryEvent {}

// No longer need InitialLoad to fetch rooms,
class HistoryInitialLoad extends HistoryEvent {}

class HistoryDeviceChanged extends HistoryEvent {
  final String deviceId;
  HistoryDeviceChanged(this.deviceId);
}
