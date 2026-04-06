import 'package:flutter/material.dart';

class Config {
  static MediaQueryData? mediaQueryData;
  static double screenWidth  = 0;
  static double screenHeight = 0;

  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth    = mediaQueryData!.size.width;
    screenHeight   = mediaQueryData!.size.height;
  }

  // ── Brand colours ─────────────────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF1A73E8);
  static const Color secondaryColor = Color(0xFF34A853);
  static const Color accentColor    = Color(0xFFFFA000);
  static const Color errorColor     = Color(0xFFD32F2F);
  static const Color bgColor        = Color(0xFFF8F9FA);
  static const Color cardColor      = Colors.white;
  static const Color textDark       = Color(0xFF202124);
  static const Color textMid        = Color(0xFF5F6368);
  static const Color textLight      = Color(0xFF9AA0A6);
  static const Color dividerColor   = Color(0xFFE8EAED);

  // Category chip colour pairs  [background, foreground]
  static const Map<String, List<Color>> catColors = {
    'General':       [Color(0xFFE3F2FD), Color(0xFF1565C0)],
    'Cardiology':    [Color(0xFFFFEBEE), Color(0xFFC62828)],
    'Respirations':  [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    'Dermatology':   [Color(0xFFFFF3E0), Color(0xFFE65100)],
    'Gynaecology':   [Color(0xFFFCE4EC), Color(0xFFAD1457)],
    'Dental':        [Color(0xFFE8EAF6), Color(0xFF283593)],
    'Orthopaedics':  [Color(0xFFF3E5F5), Color(0xFF6A1B9A)],
    'Neurology':     [Color(0xFFE0F7FA), Color(0xFF00695C)],
    'Paediatrics':   [Color(0xFFFFF8E1), Color(0xFFF57F17)],
    'Psychiatry':    [Color(0xFFE8F5E9), Color(0xFF1B5E20)],
  };

  static List<Color> categoryColor(String? cat) =>
      catColors[cat] ?? [const Color(0xFFF1F3F4), const Color(0xFF3C4043)];

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const SizedBox spaceXS     = SizedBox(height: 8);
  static const SizedBox spaceSmall  = SizedBox(height: 16);
  static const SizedBox spaceMedium = SizedBox(height: 24);
  static const SizedBox spaceLarge  = SizedBox(height: 40);
  static const SizedBox hSpaceSmall = SizedBox(width: 8);
  static const SizedBox hSpaceMed   = SizedBox(width: 16);

  // ── Input borders ─────────────────────────────────────────────────────────
  static final outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: dividerColor, width: 1.5),
  );
  static final focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: primaryColor, width: 2),
  );
  static final errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: errorColor, width: 1.5),
  );

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primaryColor,
    scaffoldBackgroundColor: bgColor,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textDark, fontSize: 18, fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: dividerColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border:        outlinedBorder,
      enabledBorder: outlinedBorder,
      focusedBorder: focusedBorder,
      errorBorder:   errorBorder,
      focusedErrorBorder: errorBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      floatingLabelStyle: const TextStyle(color: primaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: primaryColor),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textLight,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1),
  );
}