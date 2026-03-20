abstract class UsersEvent {}

class LoadUsers extends UsersEvent {}

class CreateUserRequested extends UsersEvent {
  final String username;
  final String password;
  final String role;

  CreateUserRequested({
    required this.username,
    required this.password,
    required this.role,
  });
}

class DeleteUserRequested extends UsersEvent {
  final String username;
  DeleteUserRequested(this.username);
}
