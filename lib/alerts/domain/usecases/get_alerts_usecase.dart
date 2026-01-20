import '../entities/alert_entity.dart';
import '../repositories/alerts_repository.dart';

class GetAlertsUseCase {
  final AlertsRepository repository;

  GetAlertsUseCase(this.repository);

  Future<List<AlertEntity>> call(String room) async {
    return await repository.getAlerts(room);
  }
}
