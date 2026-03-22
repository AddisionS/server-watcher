import '../../domain/entities/config_entities.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/config_data_source.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigRemoteDataSource remoteDataSource;

  ConfigRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ThresholdsEntity> getThresholds() =>
      remoteDataSource.fetchThresholds();

  @override
  Future<void> updateThresholds(ThresholdsEntity thresholds) =>
      remoteDataSource.postThresholds(thresholds);

  @override
  Future<ContactEntity> getContacts() => remoteDataSource.fetchContacts();

  @override
  Future<void> addEmail(String email) => remoteDataSource.addEmail(email);

  @override
  Future<void> removeEmail(String email) => remoteDataSource.removeEmail(email);

  @override
  Future<void> addPhone(String phone) => remoteDataSource.addPhone(phone);

  @override
  Future<void> removePhone(String phone) => remoteDataSource.removePhone(phone);
}
