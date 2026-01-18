// We import the entity we defined in the Home feature
import '../../../home/domain/entities/sensor_data_entity.dart';

abstract class HistoryRepository {
  // Returns a Future because fetching history is a one-time async action
  Future<List<SensorData>> get24HourHistory(String room);
}
