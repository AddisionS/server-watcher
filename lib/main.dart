import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports from your layers
import 'auth/data/datasources/auth_datasource.dart';
import 'auth/data/repositories/repo_impl.dart';
import 'auth/presentation/bloc/auth_bloc.dart';
import 'auth/presentation/bloc/auth_event.dart';
import 'auth/presentation/pages/login_page.dart';
import 'auth/domain/usecases/login_usecase.dart';
import 'auth/domain/usecases/logout_usecase.dart';
import 'auth/domain/usecases/auth_check_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    final authDataSource = AuthDataSourceImpl(
      sharedPreferences: sharedPreferences,
    );

    final authRepository = AuthRepositoryImpl(authDataSource: authDataSource);

    final loginUseCase = LoginUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final checkAuthStatusUseCase = CheckAuthStatusUseCase(authRepository);

    return BlocProvider(
      create: (context) => AuthBloc(
        loginUseCase: loginUseCase,
        checkAuthStatusUseCase: checkAuthStatusUseCase,
        logoutUseCase: logoutUseCase,
      )..add(AuthCheckCacheRequested()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}
