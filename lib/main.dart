import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'app_theme.dart';
import 'auth/data/datasources/auth_datasource.dart';
import 'auth/data/repositories/repo_impl.dart';
import 'auth/domain/usecases/login_usecase.dart';
import 'auth/domain/usecases/logout_usecase.dart';
import 'auth/domain/usecases/auth_check_usecase.dart';
import 'auth/presentation/bloc/auth_bloc.dart';
import 'auth/presentation/bloc/auth_event.dart';

import 'devices/data/datasources/devices_datasource.dart';
import 'devices/data/repositories/devices_repository_impl.dart';
import 'devices/domain/usecases/device_usecases.dart';
import 'devices/presentation/bloc/devices_bloc.dart';
import 'devices/presentation/bloc/devices_event.dart';

import '/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

// Changed to StatefulWidget — router and blocs must not be recreated on rebuild
class MyApp extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final http.Client _httpClient;
  late final AuthBloc _authBloc;
  late final DevicesBloc _devicesBloc;
  late final DevicesRepositoryImpl _devicesRepo;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _httpClient = http.Client();

    final authDataSource = AuthDataSourceImpl(
      client: _httpClient,
      sharedPreferences: widget.sharedPreferences,
    );
    final authRepository = AuthRepositoryImpl(authDataSource: authDataSource);

    _authBloc = AuthBloc(
      loginUseCase: LoginUseCase(authRepository),
      checkAuthStatusUseCase: CheckAuthStatusUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
    )..add(AuthCheckCacheRequested());

    _devicesRepo = DevicesRepositoryImpl(
      DevicesRemoteDataSourceImpl(
        client: _httpClient,
        sharedPreferences: widget.sharedPreferences,
      ),
    );

    _devicesBloc = DevicesBloc(
      getDevices: GetDevicesUseCase(_devicesRepo),
      addDevice: AddDeviceUseCase(_devicesRepo),
      updateDevice: UpdateDeviceUseCase(_devicesRepo),
      removeDevice: RemoveDeviceUseCase(_devicesRepo),
    )..add(LoadDevices());

    // Router is created AFTER auth bloc exists so it can reference its state
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _devicesBloc.close();
    _httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<http.Client>(create: (_) => _httpClient),
        RepositoryProvider<SharedPreferences>(
          create: (_) => widget.sharedPreferences,
        ),
        RepositoryProvider<DevicesRepositoryImpl>(create: (_) => _devicesRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<DevicesBloc>.value(value: _devicesBloc),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Server Watcher',
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.darkTheme,
          routerConfig: _router, // <-- replaces `home:`
        ),
      ),
    );
  }
}
