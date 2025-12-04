import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- COLOR PALETTE ---
  // Primary (Vitality & Stability)
  static const Color primaryGreen = Color(0xFF00695C); // Deep Emerald
  static const Color primaryGreenLight = Color(0xFF4DB6AC);
  static const Color primaryGreenDark = Color(0xFF004D40);

  // Secondary (Energy & Alert)
  static const Color secondaryYellow = Color(0xFFFFC107); // Golden Rod
  static const Color secondaryYellowDark = Color(0xFFFFA000);

  // Backgrounds & Surfaces (Cleanliness)
  static const Color creamBackground = Color(0xFFF5F5F5); // Off-White
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212); // Dark Charcoal
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textBlack = Color(0xFF212121);
  static const Color textGrey = Color(0xFF757575);
  static const Color textWhite = Color(0xFFFFFFFF);

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: creamBackground,

      // Define Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        onPrimary: textWhite,
        secondary: secondaryYellow,
        onSecondary: textBlack,
        surface: surfaceWhite,
        onSurface: textBlack,
        error: Colors.redAccent,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: textWhite, // Icons and text color
        elevation: 0,
        centerTitle: true,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(ThemeData.light().textTheme, textBlack),

      // Input Decoration (Text Fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.montserrat(color: textGrey),
        hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade400),
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: darkBackground,

      // Define Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        onPrimary: textWhite,
        secondary: secondaryYellow,
        onSecondary: textBlack,
        surface: darkSurface,
        onSurface: textWhite,
        error: Colors.redAccent,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textWhite,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(ThemeData.dark().textTheme, textWhite),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade400),
      ),
    );
  }

  // --- TEXT TYPOGRAPHY BUILDER ---
  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return base.copyWith(
      // Headings use POPPINS (Bold, Modern)
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Body text uses MONTSERRAT (Clean, Readable)
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor.withOpacity(0.8),
      ),
      labelLarge: GoogleFonts.montserrat( // Used for buttons
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}