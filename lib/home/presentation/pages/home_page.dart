import 'package:flutter/material.dart';
import '../../../../auth/domain/entities/user_entity.dart';

class HomePage extends StatelessWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          // We will add the Logout button logic back later
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // We will fix this connection later
            },
          ),
        ],
      ),
      // We will build the Side Menu (Drawer) here later
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Menu")),
            const ListTile(title: Text("Dashboard")),
            // LOGIC: Only show this if role is admin
            if (user.role == 'admin')
              const ListTile(
                title: Text("Configuration"),
                leading: Icon(Icons.settings),
              ),
          ],
        ),
      ),
      body: const Center(child: Text("Graphs will go here")),
    );
  }
}
