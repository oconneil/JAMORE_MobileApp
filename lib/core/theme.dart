import 'package:flutter/material.dart';

abstract final class JamoreColors {
  static const primary = Color(0xFF0099CC);
  static const primaryDark = Color(0xFF007FA8);

  /// Soft brand tint for chips, tonal buttons, and avatars.
  static const primarySoft = Color(0xFFDEF3FA);
  static const canvas = Color(0xFFF4F6FA);
  static const surface = Colors.white;
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFEEF1F6);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFB91C1C);
}

abstract final class JamoreTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: JamoreColors.primary,
      onPrimary: Colors.white,
      secondary: Color(0xFFFDE68A),
      // Tonal surfaces (e.g. IconButton.filledTonal) default to the secondary
      // container; keep them brand-blue instead of the amber accent.
      secondaryContainer: JamoreColors.primarySoft,
      onSecondaryContainer: JamoreColors.primaryDark,
      surface: JamoreColors.surface,
      onSurface: JamoreColors.ink,
      error: JamoreColors.danger,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: JamoreColors.canvas,
      fontFamily: 'IBM Plex Sans Thai Looped',
      visualDensity: VisualDensity.standard,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: JamoreColors.ink,
        displayColor: JamoreColors.ink,
        fontFamilyFallback: const [
          'IBM Plex Sans Thai',
          'Noto Sans Thai',
          'Arial',
          'sans-serif',
        ],
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: JamoreColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: JamoreColors.ink,
      ),
      // Without this the M3 selected pill defaults to the (amber) secondary
      // container; keep nav selection on-brand instead.
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: JamoreColors.primary.withValues(alpha: .14),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? JamoreColors.primary
                : JamoreColors.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? JamoreColors.primary
                : JamoreColors.muted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: JamoreColors.primary.withValues(alpha: .14),
        selectedIconTheme: const IconThemeData(color: JamoreColors.primary),
        unselectedIconTheme: const IconThemeData(color: JamoreColors.muted),
        selectedLabelTextStyle: const TextStyle(
          color: JamoreColors.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: const TextStyle(color: JamoreColors.muted),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
