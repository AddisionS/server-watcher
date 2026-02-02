import 'package:flutter_bloc/flutter_bloc.dart';
import '/auth/domain/entities/user_entity.dart';
import '/auth/domain/usecases/auth_check_usecase.dart';
import '/auth/domain/usecases/logout_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final LogoutUseCase logoutUseCase;
  final LoginUseCase loginUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.checkAuthStatusUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        //Call the Domain Layer to login
        final user = await loginUseCase.call(event.username, event.password);
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
    on<AuthCheckCacheRequested>((event, emit) async {
      try {
        final UserEntity? user = await checkAuthStatusUseCase.call();
        if (user != null) {
          emit(AuthSuccess(user));
        }
      } catch (e) {
        emit(AuthFailure("Session Check Faild"));
      }
    });
    on<AuthLogoutRequested>((event, emit) {
      try {
        emit(AuthLoading());
        logoutUseCase.call();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
