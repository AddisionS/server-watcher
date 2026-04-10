abstract class DevicesEvent {}

class LoadDevices extends DevicesEvent {}

class SelectDevice extends DevicesEvent {
  final String deviceId;
  SelectDevice(this.deviceId);
}

class AddDeviceRequested extends DevicesEvent {
  final String roomName;
  AddDeviceRequested(this.roomName);
}

class UpdateDeviceRequested extends DevicesEvent {
  final String id;
  final String newRoomName;
  UpdateDeviceRequested({required this.id, required this.newRoomName});
}

class RemoveDeviceRequested extends DevicesEvent {
  final String id;
  RemoveDeviceRequested(this.id);
}

class RefreshDeviceStatuses extends DevicesEvent {}
