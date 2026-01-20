import '../../../config/domain/entities/config_entities.dart';
import '../repositories/home_repo.dart';

class GetThresholdsUseCase {
  final HomeRepository repository;

  GetThresholdsUseCase(this.repository);

  Future<ThresholdsEntity> call() async {
    return await repository.getThresholds();
  }
}
