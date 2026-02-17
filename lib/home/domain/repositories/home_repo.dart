import '../entities/sensor_data_entity.dart';

abstract class HomeRepository {
  Stream<SensorData> getSensorStream(String deviceId);
}
