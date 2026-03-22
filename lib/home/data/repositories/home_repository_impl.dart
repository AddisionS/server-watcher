import '../../domain/entities/sensor_data_entity.dart';
import '../../domain/repositories/home_repo.dart';
import '../datasources/home_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<SensorData> getSensorStream(String deviceId) {
    return remoteDataSource.getSensorStream(deviceId);
  }
}
