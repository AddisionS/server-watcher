import '../../domain/entities/device_entity.dart';
import '../../domain/entities/device_file_result.dart';
import '../../domain/entities/device_status_info.dart';
import '../../domain/repositories/devices_repository.dart';
import '../datasources/devices_datasource.dart'; // Use Remote Source

class DevicesRepositoryImpl implements DevicesRepository {
  final DevicesRemoteDataSource dataSource;

  DevicesRepositoryImpl(this.dataSource);

  @override
  Future<List<DeviceEntity>> fetchDevices() async {
    // The model extends Entity, so this works automatically
    return await dataSource.getDevices();
  }

  @override
  Future<DeviceFileResult> addDevice(String roomName) async {
    // 1. Call Remote Source
    final response = await dataSource.addDevice(roomName);

    // 2. Map 'FirmwareResponse' (Data) to 'FirmwareEntity' (Domain)
    return DeviceFileResult(
      fileBytes: response.bytes,
      fileName: response.filename,
    );
  }

  @override
  Future<void> updateDevice(String id, String newRoomName) =>
      dataSource.updateDevice(id, newRoomName);

  @override
  Future<void> removeDevice(String id) => dataSource.deleteDevice(id);

  @override
  Future<Map<String, DeviceStatusInfo>> refreshStatuses(
    List<String> deviceIds,
  ) => dataSource.getDeviceStatuses(deviceIds);
}
