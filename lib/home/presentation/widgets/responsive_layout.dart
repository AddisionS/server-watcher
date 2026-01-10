import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is less than 800px, treat as Mobile
        if (constraints.maxWidth < 800) {
          return mobileBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}
