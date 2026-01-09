import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  // We just pass the data up to the parent UserEntity
  UserModel({required super.username, required super.role});

  // Since we are hardcoding, we can keep it simple for now.
}
