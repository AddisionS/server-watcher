import 'package:flutter/material.dart';
import '/home/presentation/pages/home_page.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../history/presentation/pages/history_page.dart'; // Import History Page
import '../../../config/presentation/pages/config_page.dart'; // Import config page

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

              style: const TextStyle(
                fontSize: 26,
                color: Color.fromARGB(255, 29, 28, 28),
              ),
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
