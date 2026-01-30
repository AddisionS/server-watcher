import '../../domain/entities/sensor_data_entity.dart';
import '../../domain/repositories/home_repo.dart';
import '../datasources/home_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<String>> getRooms() async {
    return await remoteDataSource.fetchRooms();
  }

  @override
  Stream<SensorData> getSensorStream(String room) {
    // The Model IS A Entity (Inheritance), so we can return it directly.
    return remoteDataSource.getSensorStream(room);
  }
}
