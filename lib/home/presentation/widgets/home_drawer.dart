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
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
// Imports
import '../../../devices/presentation/pages/device_manager_page.dart';
// ... Data source imports for injection ...

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
              toBeginningOfSentenceCase(user.username),

              style: const TextStyle(fontSize: 26, color: Colors.white),
            ),
            accountEmail: null,
            decoration: BoxDecoration(
              color: user.role == 'ADMIN'
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
          if (user.role == 'ADMIN')
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
              // 1. DO NOT create a Repository here.
              // 2. DO NOT create a BlocProvider here.

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  // 3. Just return the Page.
                  // It will look up the widget tree and find the Bloc in Main.dart
                  builder: (_) => DeviceManagerPage(user: user),
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
