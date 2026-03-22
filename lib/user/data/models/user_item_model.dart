import '../../domain/entities/user_item_entity.dart';

class UserItemModel extends UserItemEntity {
  UserItemModel({required super.username, required super.role});

  factory UserItemModel.fromJson(Map<String, dynamic> json) {
    return UserItemModel(
      username: json['username'] ?? 'Unknown',
      role: json['role'] ?? 'USER',
    );
  }
}
