import '../entities/sensor_data_entity.dart';
import '../repositories/home_repo.dart';

class GetSensorStreamUseCase {
  final HomeRepository repository;

  GetSensorStreamUseCase(this.repository);

  // Note: This returns a Stream, not a Future!
  Stream<SensorData> call(String room) {
    return repository.getSensorStream(room);
  }
}
