import 'dart:math';
import '../../domain/entities/device_entity.dart';

abstract class DevicesRemoteDataSource {
  Future<List<DeviceEntity>> getDevices();
  Future<void> addDevice(String room);
  Future<void> updateDevice(String id, String newRoom);
  Future<void> deleteDevice(String id);
}

class DevicesMockDataSourceImpl implements DevicesRemoteDataSource {
  // Static list ensures data persists even if we leave the page
  static final List<DeviceEntity> _devices = [
    DeviceEntity(id: "ESP-001", roomName: "Server Room", status: "online"),
    DeviceEntity(id: "ESP-002", roomName: "Lobby", status: "online"),
    DeviceEntity(id: "ESP-003", roomName: "Cafeteria", status: "offline"),
    DeviceEntity(id: "ESP-004", roomName: "Office", status: "maintenance"),
  ];

  @override
  Future<List<DeviceEntity>> getDevices() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate Latency
    return List.from(
      _devices,
    ); // Return a copy to prevent direct mutation issues
  }

  @override
  Future<void> addDevice(String room) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId = "ESP-${Random().nextInt(999).toString().padLeft(3, '0')}";
    _devices.add(DeviceEntity(id: newId, roomName: room, status: "online"));
  }

  @override
  Future<void> updateDevice(String id, String newRoom) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(roomName: newRoom);
    }
  }

  @override
  Future<void> deleteDevice(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _devices.removeWhere((d) => d.id == id);
  }
}
