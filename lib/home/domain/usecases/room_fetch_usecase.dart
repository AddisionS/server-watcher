import '../repositories/home_repo.dart';

class GetRoomsUseCase {
  final HomeRepository repository;

  GetRoomsUseCase(this.repository);

  Future<List<String>> call() async {
    return await repository.getRooms();
  }
}
