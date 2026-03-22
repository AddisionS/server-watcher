import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_event.dart';

class HomeDrawer extends StatelessWidget {
  final UserEntity user;
  final String activePage;

  const HomeDrawer({
    super.key,
    required this.user,
    this.activePage = "Dashboard",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Normalize role to uppercase to handle both 'admin' and 'ADMIN' from any source
    final isAdmin = user.role.toUpperCase() == 'ADMIN';

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. HEADER ---
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
                        style: TextStyle(color: theme.colorScheme.primary),
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
            onTap: () => context.go('/dashboard'),
          ),

          if (isAdmin) ...[
            _buildMenuItem(
              context: context,
              title: "Configuration",
              icon: Icons.settings_outlined,
              isActive: activePage == "System Configuration",
              onTap: () => context.go('/config'),
            ),
            _buildMenuItem(
              context: context,
              title: "Device Manager",
              icon: Icons.devices_outlined,
              isActive: activePage == "Device Manager",
              onTap: () => context.go('/devices'),
            ),
          ],

          _buildMenuItem(
            context: context,
            title: "24h Log",
            icon: Icons.history_outlined,
            isActive: activePage == "24h Log",
            onTap: () => context.go('/history'),
          ),

          _buildMenuItem(
            context: context,
            title: "Alert Logs",
            icon: Icons.warning_amber_outlined,
            isActive: activePage == "System Alerts",
            onTap: () => context.go('/alerts'),
          ),

          const Spacer(),
          const Divider(),

          // --- 4. LOGOUT ---
          // No manual navigation needed — GoRouterRefreshStream detects
          // AuthInitial state and the router redirect fires automatically
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
              },
            ),
          ),
        ],
      ),
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
        selectedTileColor: theme.colorScheme.outline,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
