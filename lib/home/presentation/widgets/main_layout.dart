import 'package:flutter/material.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import 'home_drawer.dart';

class MainLayout extends StatelessWidget {
  final UserEntity user;
  final String title;
  final Widget body;

  const MainLayout({
    super.key,
    required this.user,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = user.role == 'ADMIN'
        ? Colors.redAccent
        : Colors.blueAccent;

    // FORCE WEB LAYOUT (Sidebar + Content)
    return Scaffold(
      body: Row(
        children: [
          // 1. Permanent Sidebar
          SizedBox(width: 250, child: HomeDrawer(user: user)),

          // 2. Main Content Area
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                backgroundColor: themeColor,
                automaticallyImplyLeading: false, // No Hamburger icon
              ),
              body: body,
            ),
          ),
        ],
      ),
    );
  }
}
