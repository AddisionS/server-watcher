import '../../domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  DeviceModel({
    required super.id,
    required super.roomName,
    required super.status,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      // Map Backend fields to Entity fields
      id: json['device_id'] ?? 'UNKNOWN',
      roomName: json['device_name'] ?? 'Unknown Room',

      // HYBRID LOGIC: Backend doesn't send status yet.
      // We default to 'online' or randomize it for UI testing.
      status: 'online',
    );
  }
}
