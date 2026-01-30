import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget for healthcare application
/// Implements clean, professional header design with language switching capability
/// Follows "Accessible Medical Minimalism" design principles
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text to display in the app bar
  final String title;

  /// Whether to show the back button
  final bool showBackButton;

  /// Whether to show the language switcher
  final bool showLanguageSwitcher;

  /// Callback when language button is tapped
  final VoidCallback? onLanguageTap;

  /// Custom leading widget (overrides back button if provided)
  final Widget? leading;

  /// Custom actions widgets
  final List<Widget>? actions;

  /// Whether to center the title
  final bool centerTitle;

  /// Background color (defaults to theme background)
  final Color? backgroundColor;

  /// Elevation of the app bar
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showLanguageSwitcher = false,
    this.onLanguageTap,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build actions list
    List<Widget> appBarActions = [];

    // Add language switcher if enabled
    if (showLanguageSwitcher) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.language),
          iconSize: 24,
          tooltip: 'Change Language',
          onPressed: onLanguageTap,
          padding: const EdgeInsets.all(12),
        ),
      );
    }

    // Add custom actions if provided
    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    return AppBar(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: isDark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF212121),
      elevation: elevation,
      centerTitle: centerTitle,

      // Leading widget - back button or custom
      leading:
      leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 24,
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.all(12),
          )
              : null),

      // Title with Roboto font
      title: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
        ),
      ),

      // Actions
      actions: appBarActions.isNotEmpty ? appBarActions : null,

      // Bottom border for visual separation
      bottom: elevation == 0
          ? PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark
              ? const Color(0x1FFFFFFF)
              : const Color(0x1F000000),
        ),
      )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Custom AppBar variant with progress indicator
/// Used in assessment flow to show completion percentage
class CustomAppBarWithProgress extends StatelessWidget
    implements PreferredSizeWidget {
  /// Title text to display
  final String title;

  /// Progress value (0.0 to 1.0)
  final double progress;

  /// Whether to show the back button
  final bool showBackButton;

  /// Whether to show the language switcher
  final bool showLanguageSwitcher;

  /// Callback when language button is tapped
  final VoidCallback? onLanguageTap;

  /// Custom leading widget
  final Widget? leading;

  /// Custom actions widgets
  final List<Widget>? actions;

  /// Background color
  final Color? backgroundColor;

  const CustomAppBarWithProgress({
    super.key,
    required this.title,
    required this.progress,
    this.showBackButton = true,
    this.showLanguageSwitcher = false,
    this.onLanguageTap,
    this.leading,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build actions list
    List<Widget> appBarActions = [];

    if (showLanguageSwitcher) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.language),
          iconSize: 24,
          tooltip: 'Change Language',
          onPressed: onLanguageTap,
          padding: const EdgeInsets.all(12),
        ),
      );
    }

    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    return AppBar(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: isDark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF212121),
      elevation: 0,
      centerTitle: true,

      leading:
      leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 24,
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.all(12),
          )
              : null),

      title: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
        ),
      ),

      actions: appBarActions.isNotEmpty ? appBarActions : null,

      // Progress indicator at bottom
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: isDark
              ? const Color(0xFF1E1E1E)
              : const Color(0xFFF5F5F5),
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
          ),
          minHeight: 4,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);
}
