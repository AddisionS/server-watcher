import '../../../home/domain/entities/sensor_data_entity.dart';
import '../repositories/history_repository.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<List<SensorData>> call(String room) async {
    return await repository.get24HourHistory(room);
  }
}
