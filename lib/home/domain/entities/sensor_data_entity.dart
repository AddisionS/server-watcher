class SensorData {
  final DateTime timestamp; // To plot on X-Axis
  final double temperature; // To plot on Graph 1
  final double humidity; // To plot on Graph 2

  SensorData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
  });
}
