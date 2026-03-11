import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
// Imports from your layers
import 'auth/data/datasources/auth_datasource.dart';
import 'auth/data/repositories/repo_impl.dart';
import 'auth/presentation/bloc/auth_bloc.dart';
import 'auth/presentation/bloc/auth_event.dart';
import 'auth/presentation/pages/login_page.dart';
import 'auth/domain/usecases/login_usecase.dart';
import 'auth/domain/usecases/logout_usecase.dart';
import 'auth/domain/usecases/auth_check_usecase.dart';

// Devices - app-level providers
import 'devices/data/datasources/devices_datasource.dart';
import 'devices/data/repositories/devices_repository_impl.dart';
import 'devices/domain/usecases/device_usecases.dart';
import 'devices/presentation/bloc/devices_bloc.dart';
import 'devices/presentation/bloc/devices_event.dart';
import 'package:http/http.dart' as http;

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
    final httpClient = http.Client();
    final authDataSource = AuthDataSourceImpl(
      client: httpClient,
      sharedPreferences: sharedPreferences,
    );
    final authRepository = AuthRepositoryImpl(authDataSource: authDataSource);

    final loginUseCase = LoginUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final checkAuthStatusUseCase = CheckAuthStatusUseCase(authRepository);

    return MultiRepositoryProvider(
      providers: [
        // --- INJECT HTTP CLIENT ---
        RepositoryProvider<http.Client>(create: (context) => httpClient),

        // --- INJECT SHARED PREFERENCES ---
        RepositoryProvider<SharedPreferences>(
          create: (context) => sharedPreferences,
        ),

        // --- INJECT DEVICES REPOSITORY ---
        RepositoryProvider<DevicesRepositoryImpl>(
          create: (_) => DevicesRepositoryImpl(
            DevicesRemoteDataSourceImpl(
              client: httpClient,
              sharedPreferences: sharedPreferences,
            ),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              loginUseCase: loginUseCase,
              checkAuthStatusUseCase: checkAuthStatusUseCase,
              logoutUseCase: logoutUseCase,
            )..add(AuthCheckCacheRequested()),
          ),
          BlocProvider<DevicesBloc>(
            create: (context) => DevicesBloc(
              getDevices: GetDevicesUseCase(
                context.read<DevicesRepositoryImpl>(),
              ),
              addDevice: AddDeviceUseCase(
                context.read<DevicesRepositoryImpl>(),
              ),
              updateDevice: UpdateDeviceUseCase(
                context.read<DevicesRepositoryImpl>(),
              ),
              removeDevice: RemoveDeviceUseCase(
                context.read<DevicesRepositoryImpl>(),
              ),
            )..add(LoadDevices()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Server Watcher',

          // --- 3. FORCE DARK MODE HERE ---
          themeMode: ThemeMode.dark,

          // --- 4. DEFINE THE DARK THEME ---
          darkTheme: AppTheme.darkTheme,

          home: const LoginPage(),
        ),
      ),
    );
  }
}
