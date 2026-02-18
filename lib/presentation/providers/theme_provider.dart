import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App theme configuration with Liquid Glass light and dark modes
class AppTheme {
  final bool isDark;

  const AppTheme({this.isDark = false});

  // Animation duration for theme transitions
  static const Duration transitionDuration = Duration(milliseconds: 400);
  static const Curve transitionCurve = Curves.easeInOutCubic;

  // Light mode colors
  static const Color lightBackground = Color(0xFFF9F7F1);
  static const Color lightSurface = Colors.white;
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightCanvasBackground = Color(0xFFF9F7F1); // Warm cream

  // Dark mode colors - Warm paper-like dark (not black!)
  static const Color darkBackground = Color(0xFF1C1B1A); // Warm dark brown
  static const Color darkSurface = Color(0xFF252422); // Slightly lighter
  static const Color darkDivider = Color(0xFF3D3A36); // Warm gray-brown
  static const Color darkText = Color(0xFFF5F4F0); // Off-white cream
  static const Color darkTextSecondary = Color(0xFFA8A5A0); // Warm gray
  static const Color darkCanvasBackground = Color(
    0xFF2A2825,
  ); // Warm dark paper

  // Accent color (same for both modes)
  static const Color accentColor = Color(0xFF007AFF);

  // Getters based on mode
  Color get accent => accentColor; // Instance getter for convenience
  Color get background => isDark ? darkBackground : lightBackground;
  Color get surface => isDark ? darkSurface : lightSurface;
  Color get divider => isDark ? darkDivider : lightDivider;
  Color get text => isDark ? darkText : lightText;
  Color get textSecondary => isDark ? darkTextSecondary : lightTextSecondary;
  Color get canvasBackground =>
      isDark ? darkCanvasBackground : lightCanvasBackground;

  // Glass effect colors
  Color get glassBackground => isDark
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.white.withValues(alpha: 0.85);
  Color get glassBorder => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.white.withValues(alpha: 0.5);
  Color get glassOverlay => isDark
      ? Colors.black.withValues(alpha: 0.2)
      : Colors.black.withValues(alpha: 0.05);

  AppTheme copyWith({bool? isDark}) {
    return AppTheme(isDark: isDark ?? this.isDark);
  }
}

/// Theme notifier for managing dark/light mode
class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(const AppTheme());

  void toggleTheme() {
    state = state.copyWith(isDark: !state.isDark);
  }

  void setDarkMode(bool isDark) {
    state = state.copyWith(isDark: isDark);
  }
}

/// Provider for theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>(
  (ref) => ThemeNotifier(),
);
