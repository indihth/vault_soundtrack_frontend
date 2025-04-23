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
    textTheme: ThemeData.dark().textTheme.copyWith(
          titleMedium: TextStyle(
            color: Color(0xFFFFFFFF),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: Colors.black87,
          ),
        )

    // More light theme properties here
    );
