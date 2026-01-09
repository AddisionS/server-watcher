import 'package:flutter/material.dart';
import 'login_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.blueAccent),
            Text("Hello, User!", style: TextStyle(fontSize: 24)),
            Text("View-only access.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
