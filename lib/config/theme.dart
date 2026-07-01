import 'package:flutter/material.dart';

// ── Light Theme ──
const Color creamBg = Color(0xFFF5F4F0);
const Color whiteCard = Color(0xFFFFFFFF);
const Color nearBlack = Color(0xFF1A1A2E);
const Color textSecondary = Color(0xFF6B6D78);
const Color borderLight = Color(0xFFE5E4DF);
const Color primaryColor = Color(0xFF6366F1);
const Color primaryLight = Color(0xFF818CF8);
const Color primarySoft = Color(0xFFEEF2FF);
const Color accentPurple = Color(0xFF8B5CF6);
const Color accentPink = Color(0xFFEC4899);
const Color accentAmber = Color(0xFFF59E0B);
const Color accentTeal = Color(0xFF14B8A6);
const Color codeBg = Color(0xFF1A1A2E);
const Color codeText = Color(0xFFE2E8F0);

// ── Dark Theme ──
const Color darkBg = Color(0xFF0C0D14);
const Color darkCard = Color(0xFF151728);
const Color darkText = Color(0xFFE4E5F0);
const Color darkTextSecondary = Color(0xFF9092A0);
const Color darkBorder = Color(0xFF22253A);
const Color darkBorderLight = Color(0xFF1A1D30);
const Color darkPrimary = Color(0xFF818CF8);
const Color darkPrimarySoft = Color(0xFF1E1B4B);

// ── Semantic ──
const Color greenStatus = Color(0xFF22C55E);
const Color redStatus = Color(0xFFEF4444);
const Color amberStatus = Color(0xFFF59E0B);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: primaryColor,
    onPrimary: whiteCard,
    primaryContainer: primarySoft,
    onPrimaryContainer: primaryColor,
    secondary: accentPurple,
    onSecondary: whiteCard,
    surface: whiteCard,
    onSurface: nearBlack,
    surfaceContainerHighest: Color(0xFFF0EFE9),
    onSurfaceVariant: textSecondary,
    outline: borderLight,
    outlineVariant: Color(0xFFF0EFE9),
    error: redStatus,
  ),
  scaffoldBackgroundColor: creamBg,
  cardTheme: CardThemeData(
    color: whiteCard,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: whiteCard,
    foregroundColor: nearBlack,
    elevation: 0,
    scrolledUnderElevation: 0.5,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF0EFE9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: whiteCard,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: whiteCard,
    selectedItemColor: primaryColor,
    unselectedItemColor: textSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: darkPrimary,
    onPrimary: darkBg,
    primaryContainer: darkPrimarySoft,
    onPrimaryContainer: darkPrimary,
    secondary: darkPrimary,
    onSecondary: darkBg,
    surface: darkCard,
    onSurface: darkText,
    surfaceContainerHighest: darkBorderLight,
    onSurfaceVariant: darkTextSecondary,
    outline: darkBorder,
    outlineVariant: darkBorderLight,
    error: redStatus,
  ),
  scaffoldBackgroundColor: darkBg,
  cardTheme: CardThemeData(
    color: darkCard,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: darkCard,
    foregroundColor: darkText,
    elevation: 0,
    scrolledUnderElevation: 0.5,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: darkBorderLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkPrimary,
      foregroundColor: darkBg,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: darkCard,
    selectedItemColor: darkPrimary,
    unselectedItemColor: darkTextSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
);
