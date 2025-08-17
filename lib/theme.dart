import 'package:flutter/material.dart';

// Warm food-related color palette
const Color primaryColor = Color(0xFFFD140E); // 🍅 Vibrant Red
const Color secondaryColor = Color(0xFFFFC107); // 🌽 Golden Yellow
const Color backgroundColor = Color(0xFFFAE4E4); // Warm off-white background
const Color cardColor = Colors.white;
const double defaultPadding = 16.0;

ThemeData buildThemeData() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor, // ✅ replaces deprecated background
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 2,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),

    // Card styling
    cardTheme: const CardThemeData(
      color: cardColor,
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),

    // Elevated Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ListTiles (Quick Actions)
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      tileColor: Colors.yellow.shade50, // subtle yellow background
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      iconColor: primaryColor,
    ),

    // Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFB71C1C), // darker red for titles
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),

    scaffoldBackgroundColor: backgroundColor,
  );
}
