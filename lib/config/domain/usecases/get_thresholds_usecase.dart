import 'package:serverwatcher/config/domain/repositories/config_repository.dart';
import '../../../config/domain/entities/config_entities.dart';

class GetThresholdsUseCase {
  final ConfigRepository repository;

  GetThresholdsUseCase(this.repository);

  Future<ThresholdsEntity> call() async {
    return await repository.getThresholds();
  }
}
