import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the healthcare application.
/// Implements "Accessible Medical Minimalism" design style with health-focused clarity.
class AppTheme {
  AppTheme._();

  // Health-Focused Clarity Color Palette
  // Primary colors for trust and medical credibility
  static const Color primaryLight = Color(0xFF2E7D32); // Deep medical green
  static const Color primaryVariantLight = Color(
    0xFF1B5E20,
  ); // Darker green variant
  static const Color secondaryLight = Color(0xFF1565C0); // Professional blue
  static const Color secondaryVariantLight = Color(
    0xFF0D47A1,
  ); // Darker blue variant

  // Health status colors for risk communication
  static const Color successLight = Color(0xFF4CAF50); // Low-risk green
  static const Color warningLight = Color(0xFFFF9800); // Medium-risk amber
  static const Color errorLight = Color(0xFFD32F2F); // High-risk red
  static const Color accentLight = Color(0xFFFF6F00); // Warm orange for CTAs

  // Background and surface colors for maximum contrast
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceLight = Color(0xFFF5F5F5); // Light gray for cards
  static const Color cardLight = Color(0xFFF5F5F5); // Card background
  static const Color dialogLight = Color(0xFFFFFFFF); // Dialog background

  // Text colors for WCAG AA compliance
  static const Color textPrimaryLight = Color(0xFF212121); // Near-black
  static const Color textSecondaryLight = Color(0xFF757575); // Medium gray
  static const Color onPrimaryLight = Color(0xFFFFFFFF); // White on primary
  static const Color onSecondaryLight = Color(0xFFFFFFFF); // White on secondary
  static const Color onBackgroundLight = Color(
    0xFF212121,
  ); // Text on background
  static const Color onSurfaceLight = Color(0xFF212121); // Text on surface
  static const Color onErrorLight = Color(0xFFFFFFFF); // White on error

  // Utility colors
  static const Color shadowLight = Color(0x1F000000); // Subtle shadows
  static const Color dividerLight = Color(0x1F000000); // Minimal dividers

  // Text emphasis levels for hierarchy
  static const Color textHighEmphasisLight = Color(0xFF212121); // 100% opacity
  static const Color textMediumEmphasisLight = Color(0xFF757575); // 60% opacity
  static const Color textDisabledLight = Color(0x61000000); // 38% opacity

  // Dark theme colors (maintaining accessibility in low light)
  static const Color primaryDark = Color(
    0xFF66BB6A,
  ); // Lighter green for dark mode
  static const Color primaryVariantDark = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF42A5F5); // Lighter blue
  static const Color secondaryVariantDark = Color(0xFF1E88E5);

  static const Color successDark = Color(0xFF66BB6A);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color accentDark = Color(0xFFFF8A65);

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color dialogDark = Color(0xFF2D2D2D);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFF000000);

  static const Color shadowDark = Color(0x1FFFFFFF);
  static const Color dividerDark = Color(0x1FFFFFFF);

  static const Color textHighEmphasisDark = Color(0xFFFFFFFF);
  static const Color textMediumEmphasisDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0x61FFFFFF);

  /// Light theme with Accessible Medical Minimalism design
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: primaryVariantLight,
      onPrimaryContainer: onPrimaryLight,
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: secondaryVariantLight,
      onSecondaryContainer: onSecondaryLight,
      tertiary: accentLight,
      onTertiary: onPrimaryLight,
      tertiaryContainer: accentLight,
      onTertiaryContainer: onPrimaryLight,
      error: errorLight,
      onError: onErrorLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textSecondaryLight,
      outline: dividerLight,
      outlineVariant: dividerLight,
      shadow: shadowLight,
      scrim: shadowLight,
      inverseSurface: surfaceDark,
      onInverseSurface: onSurfaceDark,
      inversePrimary: primaryDark,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    dividerColor: dividerLight,

    // AppBar theme for clean header design
    appBarTheme: AppBarThemeData(
      backgroundColor: backgroundLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(color: textPrimaryLight, size: 24),
    ),

    // Card theme with subtle elevation (2.0 for cards)
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation for primary navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textMediumEmphasisLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentLight,
      foregroundColor: onPrimaryLight,
      elevation: 6.0,
    ),

    // Elevated button theme - full-width, thumb-optimized
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryLight,
        backgroundColor: primaryLight,
        minimumSize: const Size(
          double.infinity,
          48,
        ), // 48dp minimum touch target
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primaryLight, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
      ),
    ),

    // Text theme using Roboto with appropriate weights
    textTheme: _buildTextTheme(isLight: true),

    // Input decoration theme with clear borders
    inputDecorationTheme: InputDecorationThemeData(
      fillColor: backgroundLight,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: dividerLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: dividerLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorLight, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorLight, width: 2),
      ),
      labelStyle: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasisLight,
      ),
      hintStyle: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDisabledLight,
      ),
      errorStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: errorLight,
      ),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textMediumEmphasisLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.5);
        }
        return textDisabledLight;
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimaryLight),
      side: const BorderSide(color: dividerLight, width: 2),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textMediumEmphasisLight;
      }),
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: surfaceLight,
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      thumbColor: primaryLight,
      overlayColor: primaryLight.withValues(alpha: 0.2),
      inactiveTrackColor: surfaceLight,
      valueIndicatorColor: primaryLight,
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textMediumEmphasisLight,
      indicatorColor: primaryLight,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.25,
      ),
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimaryLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: backgroundLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryLight,
      contentTextStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: backgroundLight,
      ),
      actionTextColor: accentLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 6.0,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: dialogLight,
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
      ),
      contentTextStyle: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
      ),
    ),
  );

  /// Dark theme with maintained accessibility
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      primaryContainer: primaryVariantDark,
      onPrimaryContainer: onPrimaryDark,
      secondary: secondaryDark,
      onSecondary: onSecondaryDark,
      secondaryContainer: secondaryVariantDark,
      onSecondaryContainer: onSecondaryDark,
      tertiary: accentDark,
      onTertiary: onPrimaryDark,
      tertiaryContainer: accentDark,
      onTertiaryContainer: onPrimaryDark,
      error: errorDark,
      onError: onErrorDark,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: textSecondaryDark,
      outline: dividerDark,
      outlineVariant: dividerDark,
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: surfaceLight,
      onInverseSurface: onSurfaceLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    dividerColor: dividerDark,

    appBarTheme: AppBarThemeData(
      backgroundColor: backgroundDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
    ),

    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: textMediumEmphasisDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentDark,
      foregroundColor: onPrimaryDark,
      elevation: 6.0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryDark,
        backgroundColor: primaryDark,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primaryDark, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
      ),
    ),

    textTheme: _buildTextTheme(isLight: false),

    inputDecorationTheme: InputDecorationThemeData(
      fillColor: surfaceDark,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: dividerDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: dividerDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorDark, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorDark, width: 2),
      ),
      labelStyle: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasisDark,
      ),
      hintStyle: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDisabledDark,
      ),
      errorStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: errorDark,
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textMediumEmphasisDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withValues(alpha: 0.5);
        }
        return textDisabledDark;
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimaryDark),
      side: const BorderSide(color: dividerDark, width: 2),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textMediumEmphasisDark;
      }),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      linearTrackColor: surfaceDark,
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: primaryDark,
      thumbColor: primaryDark,
      overlayColor: primaryDark.withValues(alpha: 0.2),
      inactiveTrackColor: surfaceDark,
      valueIndicatorColor: primaryDark,
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: primaryDark,
      unselectedLabelColor: textMediumEmphasisDark,
      indicatorColor: primaryDark,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.25,
      ),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimaryDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: backgroundDark,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryDark,
      contentTextStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: backgroundDark,
      ),
      actionTextColor: accentDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 6.0,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: dialogDark,
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimaryDark,
      ),
      contentTextStyle: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryDark,
      ),
    ),
  );

  /// Helper method to build text theme using Roboto font family
  /// Implements Typography Standards with appropriate weights for headings, body, captions, and data
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis = isLight
        ? textHighEmphasisLight
        : textHighEmphasisDark;
    final Color textMediumEmphasis = isLight
        ? textMediumEmphasisLight
        : textMediumEmphasisDark;
    final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

    return TextTheme(
      // Display styles - Large headings
      displayLarge: GoogleFonts.roboto(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.roboto(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles - Section headings
      headlineLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.w700, // Bold for health headings
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles - Card titles and important labels
      titleLarge: GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles - Main content text
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400, // Regular weight for body
        color: textHighEmphasis,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasis,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles - Buttons and small labels
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium weight for labels
        color: textHighEmphasis,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMediumEmphasis,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textMediumEmphasis,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Helper method to get Roboto Mono for data display
  /// Used for numerical health data and risk percentages
  static TextStyle getDataTextStyle({
    required bool isLight,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    final Color textColor = isLight
        ? textHighEmphasisLight
        : textHighEmphasisDark;
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
      letterSpacing: 0,
    );
  }
}
