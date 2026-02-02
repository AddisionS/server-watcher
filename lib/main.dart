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

// Devices - app-level providers
import 'devices/data/datasources/devices_mock_data_source.dart';
import 'devices/data/repositories/devices_repository_impl.dart';
import 'devices/domain/usecases/device_usecases.dart';
import 'devices/presentation/bloc/devices_bloc.dart';
import 'devices/presentation/bloc/devices_event.dart';

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
    // final httpClient = http.Client();
    // final configDataSource = ConfigRemoteDataSourceImpl(
    //   client: httpClient,
    //   sharedPreferences: sharedPreferences,
    // );

    // final configRepo = ConfigRepositoryImpl(remoteDataSource: configDataSource);

    final authDataSource = AuthDataSourceImpl(
      sharedPreferences: sharedPreferences,
    );
    final authRepository = AuthRepositoryImpl(authDataSource: authDataSource);

    final loginUseCase = LoginUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final checkAuthStatusUseCase = CheckAuthStatusUseCase(authRepository);

    // 2. Define the Dark Color Palette
    const darkBackground = Color(0xFF121212); // Standard Dark Mode BG
    const darkSurface = Color(0xFF1E1E1E); // Cards / Sidebars
    const primaryColor = Colors.blueAccent;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DevicesRepositoryImpl>(
          create: (_) => DevicesRepositoryImpl(DevicesMockDataSourceImpl()),
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
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: darkBackground,

            // Card Styles
            cardTheme: CardThemeData(
              color: darkSurface,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // App Bar Styles
            appBarTheme: const AppBarTheme(
              backgroundColor: darkSurface,
              foregroundColor: Colors.white, // Text/Icon color
              elevation: 0,
            ),

            // Drawer / Sidebar Styles
            drawerTheme: const DrawerThemeData(backgroundColor: darkSurface),

            // Input Fields (TextFields)
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withValues(
                alpha: 0.05,
              ), // Subtle transparent white
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIconColor: Colors.white70,
              suffixIconColor: Colors.white70,
            ),
            canvasColor: darkSurface, // Important for Dropdown menu background
            // Text Styles
            textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),

            // Color Scheme
            colorScheme: const ColorScheme.dark(
              primary: primaryColor,
              surface: darkSurface,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: darkSurface),
          ),

          home: const LoginPage(),
        ),
      ),
    );
  }
}
