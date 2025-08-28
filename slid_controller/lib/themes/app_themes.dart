import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemes {
  static ThemeData buildLightTheme(double scale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 2,
        shadowColor: Colors.black12,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20 * scale,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
        iconTheme: IconThemeData(
          color: const Color(0xFF1A1A1A),
          size: 24 * scale,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scale),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scale,
            vertical: 16 * scale,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          textStyle: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: EdgeInsets.all(16 * scale),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 16 * scale, color: const Color(0xFF1A1A1A)),
        bodyMedium: TextStyle(fontSize: 14 * scale, color: const Color(0xFF1A1A1A)),
        titleLarge: TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blue;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blue.withOpacity(0.5);
          }
          return null;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: Colors.blue,
        inactiveTrackColor: Colors.grey[300],
        thumbColor: Colors.blue,
        overlayColor: Colors.blue.withOpacity(0.2),
      ),
    );
  }

  static ThemeData buildDarkTheme(double scale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: const Color(0xFFE6EDF3),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20 * scale,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE6EDF3),
        ),
        iconTheme: IconThemeData(
          color: const Color(0xFFE6EDF3),
          size: 24 * scale,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xFF21262D),
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scale),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scale,
            vertical: 16 * scale,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          textStyle: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF30363D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: EdgeInsets.all(16 * scale),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 16 * scale, color: const Color(0xFFE6EDF3)),
        bodyMedium: TextStyle(fontSize: 14 * scale, color: const Color(0xFFE6EDF3)),
        titleLarge: TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.w600, color: const Color(0xFFE6EDF3)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blue;
          }
          return Colors.grey[300];
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blue.withOpacity(0.5);
          }
          return Colors.grey[700];
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: Colors.blue,
        inactiveTrackColor: Colors.grey[700],
        thumbColor: Colors.blue,
        overlayColor: Colors.blue.withOpacity(0.2),
      ),
    );
  }
}
