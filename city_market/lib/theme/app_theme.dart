import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Enhanced Primary Colors
  static const Color primaryNavy = Color(0xFF1A365D);
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentYellow = Color(0xFFFBBF24);
  static const Color accentPurple = Color(0xFF8B5CF6);

  static const Color darkBackground = Color(0xFF1E1A16);
  static const Color darkSurface = Color(0xFF2B241E);
  static const Color darkCardBackground = Color(0xFF332B24);
  static const Color darkTextPrimary = Color(0xFFF7F1E8);
  static const Color darkTextSecondary = Color(0xFFD8CFC1);
  static const Color darkTextTertiary = Color(0xFFB5A899);
  static const Color darkBorderLight = Color(0xFF5A4E44);
  static const Color darkBorderMedium = Color(0xFF6E6157);

  static const Color lightBackground = Color(0xFFF7F1E8);
  static const Color lightSurface = Color(0xFFFFFBF5);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF2E2721);
  static const Color lightTextSecondary = Color(0xFF5E5348);
  static const Color lightTextTertiary = Color(0xFF8D7D70);
  static const Color lightBorderLight = Color(0xFFE7D8C9);
  static const Color lightBorderMedium = Color(0xFFD8C4B1);

  static const Color success = Color(0xFF2E8B57);
  static const Color warning = Color(0xFFE09F3E);
  static const Color error = Color(0xFFD8572A);
  static const Color info = Color(0xFF457B9D);

  // Enhanced Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF1A365D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFFF6B35), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFF0F9FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: primaryCyan,
        surface: lightSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackground,
      cardTheme: CardThemeData(
        color: lightCardBackground,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shadowColor: primaryNavy.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightBorderMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightBorderMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryCyan, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: lightBorderLight),
    );

    return base.copyWith(
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
        bodyColor: lightTextPrimary,
        displayColor: lightTextPrimary,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3EC2B4),
        secondary: Color(0xFFF2B880),
        surface: darkSurface,
        error: error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: darkBorderLight),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3EC2B4),
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorderMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorderMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3EC2B4), width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: darkBorderLight),
    );

    return base.copyWith(
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
    );
  }
}

class CustomColors {
  static const Color categoryTag = Color(0xFFFFE0B2);
  static const Color categoryText = Color(0xFF7A4E1D);
}
