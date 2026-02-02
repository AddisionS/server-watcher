import '../../domain/entities/device_entity.dart';

abstract class DevicesState {}

class DevicesLoading extends DevicesState {}

class DevicesLoaded extends DevicesState {
  final List<DeviceEntity> devices;
  final String? selectedDeviceId; // Track which one is highlighted

  DevicesLoaded({required this.devices, this.selectedDeviceId});

  // Helper to find the full object of selected device
  DeviceEntity? get selectedDevice {
    try {
      return devices.firstWhere((d) => d.id == selectedDeviceId);
    } catch (e) {
      return null;
    }
  }
}

class DevicesOperationSuccess extends DevicesState {
  final String message;
  DevicesOperationSuccess(this.message);
}

class DevicesError extends DevicesState {
  final String message;
  DevicesError(this.message);
}
