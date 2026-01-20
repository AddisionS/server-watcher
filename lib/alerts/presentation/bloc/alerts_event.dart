abstract class AlertsEvent {}

class AlertsInitialLoad extends AlertsEvent {}

class AlertsRoomChanged extends AlertsEvent {
  final String room;
  AlertsRoomChanged(this.room);
}
