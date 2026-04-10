import '../../domain/entities/device_entity.dart';
import '../../domain/entities/device_status_info.dart';

abstract class DevicesState {}

class DevicesLoading extends DevicesState {}

class DevicesLoaded extends DevicesState {
  final List<DeviceEntity> devices;
  final String? selectedDeviceId;
  final Map<String, DeviceStatusInfo> deviceStatuses;

  DevicesLoaded({
    required this.devices,
    this.selectedDeviceId,
    this.deviceStatuses = const {},
  });

  DevicesLoaded copyWith({
    List<DeviceEntity>? devices,
    String? selectedDeviceId,
    Map<String, DeviceStatusInfo>? deviceStatuses,
  }) {
    return DevicesLoaded(
      devices: devices ?? this.devices,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      deviceStatuses: deviceStatuses ?? this.deviceStatuses,
    );
  }

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
