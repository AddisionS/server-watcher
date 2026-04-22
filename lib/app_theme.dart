import 'package:flutter/material.dart';

class AppTheme {
  // --- Exact Hex Codes from Reference UI ---
  static const Color background = Color.fromARGB(255, 22, 22, 23);
  static const Color surface = Color.fromARGB(255, 32, 32, 36);
  static const Color outline = Color(0xFF2A2D35);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color.fromARGB(241, 255, 255, 255);

  static const Color accentNeonGreen = Color.fromRGBO(51, 242, 149, 1);
  static const Color accentNeonRed = Color(0xFFFF5252);
  // Seen in the strength meter of reference
  //static const Color accentNeonPurple = Color(0xFF9D65FF);
  static const Color accentNeonPurple = Color.fromRGBO(149, 51, 242, 1);
  static const Color interactiveBlue = Color.fromRGBO(51, 144, 242, 1);
  static const Color accentorange = Color.fromRGBO(242, 149, 51, 1);
  static ThemeData get darkTheme {
    // Base text theme using Google Fonts (Inter is a great match for the reference)
    final baseTextTheme = ThemeData.dark().textTheme.apply(fontFamily: 'Inter');

    return ThemeData(
      fontFamily: 'Inter',
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,

      // --- Color Scheme Mapping ---
      colorScheme: const ColorScheme.dark(
        surface: surface,
        outline: outline,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        primary: interactiveBlue,
        secondary: accentNeonGreen,
        error: accentNeonRed,
        tertiary: accentNeonPurple,
      ),

      // --- Typography ---
      textTheme: baseTextTheme.copyWith(
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textSecondary),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // --- Text Selection Styling ---
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: interactiveBlue, // Makes the blinking cursor Electric Blue
        selectionColor: Color(
          0x4D3B82F6,
        ), // Light blue background when text is highlighted (30% opacity)
        selectionHandleColor: interactiveBlue, // The teardrop handle on mobile
      ),

      // --- Card Styling (Flat, Bordered, No Shadow) ---
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0, // No drop shadows
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),

      // --- App Bar Styling ---
      appBarTheme: const AppBarTheme(
        backgroundColor: background, // Blends into the scaffold
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      // --- Drawer / Sidebar Styling ---
      drawerTheme: const DrawerThemeData(
        backgroundColor: background, // Sidebar matches background
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      // --- ListTile Styling (For Sidebar Menu) ---
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textSecondary,
        selectedColor: textPrimary,
        selectedTileColor: surface, // Highlight background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // --- Divider Styling ---
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 32,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03), // Very subtle fill
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Default Border (Unfocused)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        // NEW: Highlighted Border (Focused)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: interactiveBlue,
            width: 1.5,
          ), // Electric Blue glow
        ),
        // Error Border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentNeonRed, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        floatingLabelStyle: const TextStyle(
          color: interactiveBlue,
        ), // Label turns blue when typing
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // --- NEW: Neutral Button Styling ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: interactiveBlue, // Neutral primary action color
          foregroundColor: Colors.white, // Crisp white text
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
