import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../../config/presentation/pages/config_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../alerts/presentation/pages/alerts_page.dart';
import '../../../devices/presentation/pages/device_manager_page.dart';
import '../../../user/presentation/pages/user_management_page.dart';

class HomeDrawer extends StatelessWidget {
  final UserEntity user;
  final String activePage; // Used to highlight the current menu item

  const HomeDrawer({
    super.key,
    required this.user,
    this.activePage = "Dashboard",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme
          .colorScheme
          .surface, // Use surface color for the drawer background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. SLEEK TYPOGRAPHY HEADER ---
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 24, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      letterSpacing: 0.5,
                    ),
                    children: [
                      const TextSpan(text: 'Server '),
                      TextSpan(
                        text: 'Watcher',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                        ), // Neon Green
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Logged in as ${user.username}",
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),

          // --- 2. MENU LABEL ---
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 12),
            child: Text(
              "MENU",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // --- 3. MENU ITEMS ---
          _buildMenuItem(
            context: context,
            title: "Dashboard",
            icon: Icons.dashboard_outlined,
            isActive: activePage == "Dashboard",
            onTap: () => _navigate(context, HomePage(user: user)),
          ),

          if (user.role == 'ADMIN' || user.role == 'DEVELOPER') ...[
            _buildMenuItem(
              context: context,
              title: "Configuration",
              icon: Icons.settings_outlined,
              isActive: activePage == "System Configuration",
              onTap: () => _navigate(context, ConfigPage(user: user)),
            ),
            _buildMenuItem(
              context: context,
              title: "Device Manager",
              icon: Icons.devices_outlined,
              isActive: activePage == "Device Manager",
              onTap: () => _navigate(context, DeviceManagerPage(user: user)),
            ),
            _buildMenuItem(
              context: context,
              title: "User Management",
              icon: Icons.people_outline,
              isActive: activePage == "User Management",
              onTap: () =>
                  _navigate(context, UserManagementPage(currentUser: user)),
            ),
          ],

          _buildMenuItem(
            context: context,
            title: "24h Log",
            icon: Icons.history_outlined,
            isActive: activePage == "24h Log",
            onTap: () => _navigate(context, HistoryPage(user: user)),
          ),

          _buildMenuItem(
            context: context,
            title: "Alert Logs",
            icon: Icons.warning_amber_outlined,
            isActive: activePage == "System Alerts",
            onTap: () => _navigate(context, AlertsPage(user: user)),
          ),

          const Spacer(),
          const Divider(),

          // --- 4. LOGOUT ---
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                "Logout",
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isActive,
        selectedTileColor: theme.colorScheme.outline, // Highlight background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
