import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/user_usecases.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;
  final CreateUserUseCase createUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;

  UsersBloc({
    required this.getUsersUseCase,
    required this.createUserUseCase,
    required this.deleteUserUseCase,
  }) : super(UsersLoading()) {
    // Load Users
    on<LoadUsers>((event, emit) async {
      emit(UsersLoading());
      try {
        final users = await getUsersUseCase.call();
        emit(UsersLoaded(users));
      } catch (e) {
        emit(UsersError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // Create User
    on<CreateUserRequested>((event, emit) async {
      emit(UsersLoading());
      try {
        await createUserUseCase.call(
          event.username,
          event.password,
          event.role,
        );
        emit(
          UserOperationSuccess(
            "User '${event.username}' created successfully.",
          ),
        );
        add(LoadUsers()); // Refresh the list
      } catch (e) {
        emit(UsersError(e.toString().replaceAll('Exception: ', '')));
        add(LoadUsers()); // Reload list to clear loading state
      }
    });

    // Delete User
    on<DeleteUserRequested>((event, emit) async {
      emit(UsersLoading());
      try {
        await deleteUserUseCase.call(event.username);
        emit(UserOperationSuccess("User '${event.username}' deleted."));
        add(LoadUsers()); // Refresh the list
      } catch (e) {
        emit(UsersError(e.toString().replaceAll('Exception: ', '')));
        add(LoadUsers());
      }
    });
  }
}
