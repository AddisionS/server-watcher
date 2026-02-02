import 'package:flutter/material.dart';
import '/home/presentation/pages/home_page.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../history/presentation/pages/history_page.dart'; // Import History Page
import '../../../config/presentation/pages/config_page.dart'; // Import config page
import '../../../alerts/presentation/pages/alerts_page.dart';

// Imports
import '../../../devices/presentation/pages/device_manager_page.dart';
// ... Data source imports for injection ...
import '../../../devices/data/datasources/devices_mock_data_source.dart';
import '../../../devices/data/repositories/devices_repository_impl.dart';
import '../../../devices/domain/usecases/device_usecases.dart';
import '../../../devices/presentation/bloc/devices_bloc.dart';
import '../../../devices/presentation/bloc/devices_event.dart'; // For LoadDevices

class HomeDrawer extends StatelessWidget {
  final UserEntity user;

  const HomeDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;
    return Drawer(
      shape: isDesktop
          ? const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
          : null,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user.username,

              style: const TextStyle(fontSize: 26, color: Colors.white),
            ),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.white),
            decoration: BoxDecoration(
              color: user.role == 'admin'
                  ? Colors.redAccent
                  : Colors.blueAccent,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              if (!isDesktop) Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomePage(user: user)),
                (route) => false,
              );
            },
          ),

          // LOGIC: Only show for Admin
          if (user.role == 'admin')
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configuration"),
              onTap: () {
                if (!isDesktop) Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => ConfigPage(user: user)),
                  (route) => false,
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("24h Log"),
            onTap: () {
              if (!isDesktop) Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HistoryPage(user: user)),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: const Text("Alert Logs"),
            onTap: () {
              if (!isDesktop) Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => AlertsPage(user: user)),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text("Device Manager"),
            onTap: () {
              final devRepo = DevicesRepositoryImpl(
                DevicesMockDataSourceImpl(),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => DevicesBloc(
                      getDevices: GetDevicesUseCase(devRepo),
                      addDevice: AddDeviceUseCase(devRepo),
                      updateDevice: UpdateDeviceUseCase(devRepo),
                      removeDevice: RemoveDeviceUseCase(devRepo),
                    )..add(LoadDevices()),
                    child: DeviceManagerPage(user: user),
                  ),
                ),
                (route) => false,
              );
            },
          ),
          const Spacer(), // Pushes logout to bottom
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              // Trigger BLoC Logout
              context.read<AuthBloc>().add(AuthLogoutRequested());

              // Navigate to Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
