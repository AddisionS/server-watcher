import '../entities/sensor_data_entity.dart';
import '../repositories/home_repo.dart';

class GetSensorStreamUseCase {
  final HomeRepository repository;

  GetSensorStreamUseCase(this.repository);

  Stream<SensorData> call(String deviceId) {
    return repository.getSensorStream(deviceId);
  }
}
