import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_mock_data_source.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource remoteDataSource;

  AlertsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AlertEntity>> getAlerts(String room) async {
    return await remoteDataSource.fetchAlerts(room);
  }
}
