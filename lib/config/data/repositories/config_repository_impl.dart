import '../../domain/entities/config_entities.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/config_mock_data_source.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigRemoteDataSource remoteDataSource;

  ConfigRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateThresholds(ThresholdsEntity thresholds) async {
    await remoteDataSource.postThresholds(thresholds);
  }

  @override
  Future<void> updateContacts(ContactEntity contacts) async {
    await remoteDataSource.postContacts(contacts);
  }

  @override
  Future<ThresholdsEntity> getThresholds() async {
    return await remoteDataSource.fetchThresholds();
  }
}
