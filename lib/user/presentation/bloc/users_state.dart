import '../../domain/entities/user_item_entity.dart';

abstract class UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserItemEntity> users;
  UsersLoaded(this.users);
}

class UserOperationSuccess extends UsersState {
  final String message;
  UserOperationSuccess(this.message);
}

class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}
