class DeviceEntity {
  final String id;
  final String roomName;
  final String status;

  DeviceEntity({
    required this.id,
    required this.roomName,
    required this.status,
  });

  // Helper to create a copy with modified fields (useful for updates)
  DeviceEntity copyWith({String? id, String? roomName, String? status}) {
    return DeviceEntity(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      status: status ?? this.status,
    );
  }
}
