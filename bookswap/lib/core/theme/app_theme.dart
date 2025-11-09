import 'package:flutter/material.dart';

/// App theme configuration matching your new UI preferences
class AppTheme {
  static const Color primaryNavy = Color.fromARGB(255, 6, 19, 40);
  // Color palette
  static const Color accentYellow = Color.fromARGB(
    255,
    224,
    180,
    69,
  ); // Accent for icons & highlights
  static const Color textWhite = Color(0xFFFFFFFF); // White text
  static const Color cardWhite = Color(
    0xFFFFFFFF,
  ); // White for body/card surfaces
  static const Color textGray = Color.fromARGB(
    255,
    171,
    176,
    183,
  ); // Optional gray text
  // ignore: constant_identifier_names
  static const Color text_sub_heading1 = Color.fromARGB(216, 255, 255, 255);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryNavy,
      scaffoldBackgroundColor: primaryNavy, // Dark blue background
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: accentYellow), // Back arrow color
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryNavy,
        selectedItemColor: accentYellow,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card / body background style
      cardTheme: CardThemeData(
        color: cardWhite, // White cards (body background)
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentYellow,
          foregroundColor: primaryNavy,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textWhite,
          fontSize: 45,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        bodySmall: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
      ),

      // Input decorations
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite, // Input field background is white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textGray),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: accentYellow,
        secondary: accentYellow,
        surface: cardWhite,
      ),
    );
  }
}
