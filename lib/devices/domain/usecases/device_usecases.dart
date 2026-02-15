import '../entities/device_entity.dart';
import '../repositories/devices_repository.dart';
import '../entities/device_file_result.dart';

class GetDevicesUseCase {
  final DevicesRepository repo;
  GetDevicesUseCase(this.repo);
  Future<List<DeviceEntity>> call() => repo.fetchDevices();
}

class AddDeviceUseCase {
  final DevicesRepository repo;
  AddDeviceUseCase(this.repo);
  Future<DeviceFileResult> call(String roomName) => repo.addDevice(roomName);
}

class UpdateDeviceUseCase {
  final DevicesRepository repo;
  UpdateDeviceUseCase(this.repo);
  Future<void> call(String id, String newName) =>
      repo.updateDevice(id, newName);
}

class RemoveDeviceUseCase {
  final DevicesRepository repo;
  RemoveDeviceUseCase(this.repo);
  Future<void> call(String id) => repo.removeDevice(id);
}
