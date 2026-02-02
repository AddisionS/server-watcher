import '../entities/device_entity.dart';

abstract class DevicesRepository {
  Future<List<DeviceEntity>> fetchDevices();
  Future<void> addDevice(String roomName);
  Future<void> updateDevice(String id, String newRoomName);
  Future<void> removeDevice(String id);
}
