import '../entities/sensor_data_entity.dart';

abstract class HomeRepository {
  Future<List<String>> getRooms();
  Stream<SensorData> getSensorStream(String room);
}
