import 'package:go_router/go_router.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../home/presentation/pages/home_page.dart';
import '../../config/presentation/pages/config_page.dart';
import '../../history/presentation/pages/history_page.dart';
import '../../alerts/presentation/pages/alerts_page.dart';
import '../../devices/presentation/pages/device_manager_page.dart';
import '../../user/presentation/pages/user_management_page.dart';
import 'go_router_refresh_stream.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    // Global auth guard
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is AuthSuccess;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) {
        return '/login'; // Not logged in → force to login
      }
      if (isLoggedIn && isOnLogin) {
        return '/dashboard'; // Already logged in → skip login
      }
      return null; // No redirect needed
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final user = (authBloc.state as AuthSuccess).user;
          return HomePage(user: user);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) {
          final user = (authBloc.state as AuthSuccess).user;
          return HistoryPage(user: user);
        },
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) {
          final user = (authBloc.state as AuthSuccess).user;
          return AlertsPage(user: user);
        },
      ),

      // Admin-only routes: redirect back to dashboard if role doesn't match
      GoRoute(
        path: '/config',
        redirect: (context, state) {
          final authState = authBloc.state;
          if (authState is AuthSuccess && authState.user.role == 'ADMIN') {
            return null; // Allow
          }
          return '/dashboard';
        },
        builder: (context, state) {
          final user = (authBloc.state as AuthSuccess).user;
          return ConfigPage(user: user);
        },
      ),
      GoRoute(
        path: '/devices',
        redirect: (context, state) {
          final authState = authBloc.state;
          if (authState is AuthSuccess && authState.user.role == 'ADMIN') {
            return null;
          }
          return '/dashboard';
        },
        builder: (context, state) {
          final user = (authBloc.state as AuthSuccess).user;
          return DeviceManagerPage(user: user);
        },
      ),
      GoRoute(
        path: '/users',
        redirect: (context, state) {
          final authState = authBloc.state;
          if (authState is AuthSuccess && authState.user.role == 'ADMIN') {
            return null;
          }
          return '/dashboard';
        },
        builder: (context, state) {
          final user = (authBloc.state as AuthSuccess).user;
          return UserManagementPage(currentUser: user);
        },
      ),
    ],
  );
}
