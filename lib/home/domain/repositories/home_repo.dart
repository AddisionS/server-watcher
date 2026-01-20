import '../entities/sensor_data_entity.dart';
import '../../../config/domain/entities/config_entities.dart';

abstract class HomeRepository {
  Future<List<String>> getRooms();
  Stream<SensorData> getSensorStream(String room);
  Future<ThresholdsEntity> getThresholds();
}
