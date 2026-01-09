abstract class AuthEvent {}

class AuthCheckCacheRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  AuthLoginRequested({required this.username, required this.password});
}
