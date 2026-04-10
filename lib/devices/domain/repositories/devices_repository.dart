import '../entities/device_entity.dart';
import '../entities/device_file_result.dart';
import '../entities/device_status_info.dart';

abstract class DevicesRepository {
  Future<List<DeviceEntity>> fetchDevices();
  Future<DeviceFileResult> addDevice(String roomName);
  Future<void> updateDevice(String id, String newRoomName);
  Future<void> removeDevice(String id);
  Future<Map<String, DeviceStatusInfo>> refreshStatuses(List<String> deviceIds);
}
