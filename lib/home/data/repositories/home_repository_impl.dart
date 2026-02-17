import '../../domain/entities/sensor_data_entity.dart';
import '../../domain/repositories/home_repo.dart';
import '../datasources/home_datasource.dart'; // Use Remote Source

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  // REMOVED: getRooms() implementation

  @override
  Stream<SensorData> getSensorStream(String deviceId) {
    return remoteDataSource.getSensorStream(deviceId);
  }
}
