import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Color Palette (merged)
const Color primaryColor = Color(0xFFF84440); // 🍅 Vibrant Red
const Color secondaryColor = Color(0xFFFFC107); // 🌽 Golden Yellow
const Color backgroundColor = Color.fromARGB(255, 207, 207, 207); // Warm off-white background
const Color cardColor = Colors.white;

// Legacy constants from constants.dart
const Color titleColor = Color(0xFF010F07);
const Color accentColor = Color(0xFF603D35);
const Color bodyTextColor = Color(0xFF868686);
const Color inputColor = Color(0xFFFBFBFB);

const double defaultPadding = 16.0;
const Duration kDefaultDuration = Duration(milliseconds: 250);

const TextStyle kButtonTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const EdgeInsets kTextFieldPadding = EdgeInsets.symmetric(
  horizontal: defaultPadding,
  vertical: defaultPadding,
);

// Text Field Decoration
const OutlineInputBorder kDefaultOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(6)),
  borderSide: BorderSide(
    color: Color(0xFFF3F2F2),
  ),
);

const InputDecoration otpInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.zero,
  counterText: "",
  errorStyle: TextStyle(height: 0),
);

const kErrorBorderSide = BorderSide(color: Colors.red, width: 1);

// Validators
final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(6, errorText: 'Password must be at least 6 characters long'),
]);

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: 'Enter a valid email address'),
]);

final requiredValidator = RequiredValidator(errorText: 'This field is required');
final matchValidator = MatchValidator(errorText: 'Passwords do not match');

final phoneNumberValidator = MinLengthValidator(
  10,
  errorText: 'Phone Number must be at least 10 digits long',
);

// Common Text
final Center kOrText = Center(
  child: Text("Or", style: TextStyle(color: titleColor)),
);

// Main Theme
ThemeData buildThemeData() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor, // ✅ replaces deprecated background
    ),

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

    cardTheme: const CardThemeData(
      color: cardColor,
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      tileColor: Colors.yellow.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      iconColor: primaryColor,
    ),

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
