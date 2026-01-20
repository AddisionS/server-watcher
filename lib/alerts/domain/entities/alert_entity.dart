class AlertEntity {
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final String message; // e.g., "High Temperature detected!"

  AlertEntity({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.message,
  });
}
