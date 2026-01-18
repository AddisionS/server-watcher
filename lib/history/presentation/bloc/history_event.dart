//To Manage state of history page
abstract class HistoryEvent {}

// Fired when page opens: fetches list of rooms
class HistoryInitialLoad extends HistoryEvent {}

// Fired when user selects a different room
class HistoryRoomChanged extends HistoryEvent {
  final String room;
  HistoryRoomChanged(this.room);
}
