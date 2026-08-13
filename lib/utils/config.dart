import 'package:flutter/material.dart';

class Config {
  static MediaQueryData? mediaQueryData;
  static double screenWidth = 0;
  static double screenHeight = 0;

  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData!.size.width;
    screenHeight = mediaQueryData!.size.height;
  }

  // ── Premium Brand Palette ──────────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF0A6EFF);   // Electric blue
  static const Color primaryDark    = Color(0xFF0050CC);
  static const Color primaryLight   = Color(0xFF5BA3FF);
  static const Color accentTeal     = Color(0xFF00D4AA);   // Teal accent
  static const Color accentAmber    = Color(0xFFFFB300);
  static const Color secondaryColor = Color(0xFF00C896);
  static const Color errorColor     = Color(0xFFFF4757);
  static const Color bgColor        = Color(0xFFF0F4FF);   // Soft blue-white
  static const Color bgDark         = Color(0xFF0D1117);
  static const Color cardColor      = Colors.white;
  static const Color textDark       = Color(0xFF0D1117);
  static const Color textMid        = Color(0xFF6B7280);
  static const Color textLight      = Color(0xFFB0B7C3);
  static const Color dividerColor   = Color(0xFFE8EEFF);
  static const Color surfaceColor   = Color(0xFFF8FAFF);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A6EFF), Color(0xFF00C5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient doctorCardGradient = LinearGradient(
    colors: [Color(0xFF0A6EFF), Color(0xFF00C5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C896), Color(0xFF00D4AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const SizedBox spaceXS     = SizedBox(height: 8);
  static const SizedBox spaceSmall  = SizedBox(height: 16);
  static const SizedBox spaceMedium = SizedBox(height: 24);
  static const SizedBox spaceLarge  = SizedBox(height: 40);
  static const SizedBox hSpaceSmall = SizedBox(width: 8);
  static const SizedBox hSpaceMed   = SizedBox(width: 16);

  // ── Input Borders ─────────────────────────────────────────────────────────
  static final outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: dividerColor, width: 1.5),
  );
  static final focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: primaryColor, width: 2),
  );
  static final errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: errorColor, width: 1.5),
  );

  // Category colors
  static const Map<String, List<Color>> catColors = {
    'General':      [Color(0xFFEEF6FF), Color(0xFF0A6EFF)],
    'Cardiology':   [Color(0xFFFFEEEE), Color(0xFFFF4757)],
    'Respirations': [Color(0xFFEEFFF8), Color(0xFF00C896)],
    'Dermatology':  [Color(0xFFFFF8EE), Color(0xFFFF8C00)],
    'Gynaecology':  [Color(0xFFFFEEF8), Color(0xFFFF69B4)],
    'Dental':       [Color(0xFFEEEEFF), Color(0xFF6C5CE7)],
    'Orthopaedics': [Color(0xFFEEF8FF), Color(0xFF00BFFF)],
    'Neurology':    [Color(0xFFEEFFFF), Color(0xFF00D4AA)],
    'Paediatrics':  [Color(0xFFFFFBEE), Color(0xFFFFB300)],
    'Psychiatry':   [Color(0xFFF5EEFF), Color(0xFF8B5CF6)],
  };

  static Color accentColor= Colors.blueAccent;

  static List<Color> categoryColor(String? cat) =>
      catColors[cat] ?? [const Color(0xFFF0F4FF), primaryColor];

  // ── Premium ThemeData ─────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: bgColor,
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Nunito',
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: outlinedBorder,
      enabledBorder: outlinedBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      floatingLabelStyle: const TextStyle(color: primaryColor),
      hintStyle: const TextStyle(color: textLight),
      labelStyle: const TextStyle(color: textMid),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: primaryColor),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textLight,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: textDark),
      headlineLarge: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: textDark),
      headlineMedium: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: textDark),
      titleLarge: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: textDark),
      bodyLarge: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, color: textDark),
      bodyMedium: TextStyle(fontFamily: 'Nunito', color: textMid),
    ),
  );
}