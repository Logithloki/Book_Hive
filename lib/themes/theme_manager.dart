import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeManager with ChangeNotifier {
  // Define themes with accessibility in mind
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors
          .black87, // Slightly softer than pure black for better readability
      elevation: 2, // Add some elevation for depth
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
      titleLarge: TextStyle(
          color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    cardTheme: const CardTheme(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(Colors.orange),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white, // White text on orange for better contrast
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.orange,
      secondary: Colors.orangeAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black87,
      background: Colors.grey[50]!,
      onBackground: Colors.black87,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor:
        const Color(0xFF121212), // Material dark theme background
    appBarTheme: const AppBarTheme(
      backgroundColor:
          Color(0xFF1E1E1E), // Slightly lighter than scaffold background
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      titleLarge: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF2C2C2C), // Slightly lighter than background for contrast
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Colors.orange[700], // Darker orange for better contrast
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(Colors.orangeAccent),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.orange[700]!,
      secondary: Colors.orangeAccent[400]!,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      surface: const Color(0xFF2C2C2C),
      onSurface: Colors.white,
      background: const Color(0xFF121212),
      onBackground: Colors.white,
    ),
  );
  // Will store current theme mode
  bool _isDarkMode = false;
  // Track if we should follow system or use manual setting
  bool _followSystem = true;

  ThemeManager() {
    // Initialize with system theme
    _updateThemeFromSystem();
  }

  // Get the current theme based on dark mode setting
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  // Get current dark mode state
  bool get isDarkMode => _isDarkMode;

  // Get whether we're following system theme
  bool get followsSystem => _followSystem;

  // Toggle between light and dark theme
  void toggleTheme() {
    _followSystem = false; // No longer follow system
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Set theme to match system settings
  void useSystemTheme() {
    _followSystem = true;
    _updateThemeFromSystem();
    notifyListeners();
  }

  // Update theme based on system preference
  void _updateThemeFromSystem() {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode = brightness == Brightness.dark;
    notifyListeners();
  }

  // Listen for system theme changes
  void listenToSystemThemeChanges() {
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
      if (_followSystem) {
        _updateThemeFromSystem();
      }
    };
  }
}
