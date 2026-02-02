import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/devices_repository.dart';
import '../datasources/devices_mock_data_source.dart';

class DevicesRepositoryImpl implements DevicesRepository {
  final DevicesRemoteDataSource dataSource;

  DevicesRepositoryImpl(this.dataSource);

  @override
  Future<List<DeviceEntity>> fetchDevices() => dataSource.getDevices();

  @override
  Future<void> addDevice(String roomName) => dataSource.addDevice(roomName);

  @override
  Future<void> updateDevice(String id, String newRoomName) =>
      dataSource.updateDevice(id, newRoomName);

  @override
  Future<void> removeDevice(String id) => dataSource.deleteDevice(id);
}
