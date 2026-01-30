import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/localization_service.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen - Branded app launch experience with namaste animation
/// Initializes core services and determines navigation flow based on user preferences
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  /// Initialize fade animation for smooth transitions
  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  /// Initialize app services and check user preferences
  Future<void> _initializeApp() async {
    try {
      // Minimum display time for branding
      await Future.delayed(const Duration(milliseconds: 2500));

      // Initialize Localization and load language preferences
      await LocalizationService().init();
      final savedLanguage = LocalizationService().langCode;

      if (!mounted) return;

      // Navigate based on language preference (check if default 'en' was actually a saved choice or just default)
      // Since defaults to 'en', we need to check if it was set. LocalizationService handles it.
      // Actually, standard pattern: if (pref exists) go home, else select lang.
      final prefs = await SharedPreferences.getInstance();
      final hasLanguageSet = prefs.containsKey('selected_language');

      if (hasLanguageSet) {
        // User has selected language before
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/symptoms-selection-screen');
      } else {
        // First time user, show language selection
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/language-selection-screen');
      }
    } catch (e) {
      // On error, default to language selection
      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed('/language-selection-screen');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              const Color(0xFF1B5E20),
              const Color(0xFF2E7D32),
              const Color(0xFF4CAF50),
            ]
                : [
              const Color(0xFF2E7D32),
              const Color(0xFF4CAF50),
              const Color(0xFF66BB6A),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildLogoSection(theme),
                const SizedBox(height: 32),
                _buildAppNameSection(theme),
                const SizedBox(height: 16),
                _buildTaglineSection(theme),
                const Spacer(flex: 2),
                _buildLoadingIndicator(theme),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build logo section with static icon (Lottie removed as asset missing)
  Widget _buildLogoSection(ThemeData theme) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.health_and_safety,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build app name section
  Widget _buildAppNameSection(ThemeData theme) {
    return Text(
      'SwasthyaSahayak',
      style: theme.textTheme.headlineLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build tagline section
  Widget _buildTaglineSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Text(
        'Your Health Companion',
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w400,
          fontSize: 16,
          letterSpacing: 0.15,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(ThemeData theme) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
