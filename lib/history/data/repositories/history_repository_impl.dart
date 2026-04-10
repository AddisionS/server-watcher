import '../../../../home/domain/entities/sensor_data_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SensorData>> get24HourHistory(String room) async {
    return await remoteDataSource.fetchHistory(room);
  }
}
