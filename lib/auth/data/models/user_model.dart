import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.username,
    required super.role,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String username) {
    return UserModel(
      username: username,
      role: json['role'] ?? 'user',
      token: json['access_token'] ?? '',
    );
  }
  factory UserModel.fromCache(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'],
      role: map['role'],
      token: map['token'],
    );
  }
}
