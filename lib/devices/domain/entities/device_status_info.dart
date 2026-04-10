class DeviceStatusInfo {
  final String state;
  final bool alertActive;
  final String firmware;

  const DeviceStatusInfo({
    required this.state,
    required this.alertActive,
    required this.firmware,
  });
}
