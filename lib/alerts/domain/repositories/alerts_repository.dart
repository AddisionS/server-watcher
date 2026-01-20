import '../entities/alert_entity.dart';

abstract class AlertsRepository {
  Future<List<AlertEntity>> getAlerts(String room);
}
