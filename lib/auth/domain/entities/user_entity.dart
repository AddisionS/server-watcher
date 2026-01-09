class UserEntity {
  final String username;
  final String role; // We will expect values like 'admin' or 'guest'

  UserEntity({
    required this.username,
    required this.role,
  });
}