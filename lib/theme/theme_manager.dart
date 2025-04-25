import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blueAccent,
    colorScheme: const ColorScheme.light(
      primary: Colors.blueAccent,
      secondary: Colors.tealAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    cardColor: Colors.white,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueAccent[400],
    colorScheme: const ColorScheme.dark(
      primary: Colors.blueAccent,
      secondary: Colors.tealAccent,
    ),
    appBarTheme: AppBarTheme(backgroundColor: Colors.grey[900]),
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey[800],
  );
}
