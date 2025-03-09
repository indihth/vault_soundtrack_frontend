import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF121212),
    // surface: Colors.grey.shade900,
    primary: Color(0xFFFFFFFF),
    // primary: Colors.grey.shade800,
    secondary: Color(0xFF777777),
    tertiary: Color(0xFF1ED760),
    // secondary: Colors.grey.shade600,
    inversePrimary: Color(0xFF121212),
    // inversePrimary: Colors.grey.shade300,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Color(0xFFB3B3B3),
        // bodyColor: Colors.grey[200],
        displayColor: Colors.white,
      ),
  // More light theme properties here
);
