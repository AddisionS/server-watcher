import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_data_source.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource remoteDataSource;

  AlertsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AlertEntity>> getAlerts(String deviceId) async {
    final allAlerts = await remoteDataSource.fetchAlerts();
    // Filter client-side by device_id since the API returns all alerts globally
    return allAlerts.where((a) => a.deviceId == deviceId).toList();
  }
}
