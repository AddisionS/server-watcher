import '../../domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user; // <--- The UI needs this to know if it's Admin or Guest!
  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String message; // <--- The UI needs this to show the Snackbar error
  AuthFailure(this.message);
}