import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../services/localization_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';

/// Language Selection Screen
/// Enables users to choose their preferred language (Hindi, English, Marathi)
/// with persistent storage for future app sessions
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _languages = [
    {'code': 'hi', 'name': 'हिंदी', 'displayName': 'Hindi', 'icon': 'language'},
    {
      'code': 'en',
      'name': 'English',
      'displayName': 'English',
      'icon': 'language',
    },
    {
      'code': 'mr',
      'name': 'मराठी',
      'displayName': 'Marathi',
      'icon': 'language',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    // LocalizationService is likely already initialized in Splash, but safe to call
    await LocalizationService().init();
    setState(() {
      _selectedLanguage = LocalizationService().langCode;
    });
  }

  Future<void> _saveLanguageAndContinue() async {
    if (_selectedLanguage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await LocalizationService().changeLanguage(_selectedLanguage!);

      if (!mounted) return;

      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed('/symptoms-selection-screen');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving language. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getContinueButtonText() {
    if (_selectedLanguage == null) return 'Continue';

    final language = _languages.firstWhere(
          (lang) => lang['code'] == _selectedLanguage,
      orElse: () => _languages[1],
    );

    switch (_selectedLanguage) {
      case 'hi':
        return 'जारी रखें';
      case 'mr':
        return 'सुरू ठेवा';
      default:
        return 'Continue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Select Language',
        showBackButton: true,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 3.h,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),

                        // App Logo
                        Container(
                          width: 25.w,
                          height: 25.w,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'health_and_safety',
                              size: 15.w,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Title
                        Text(
                          'Choose Your Language',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 1.h),

                        // Subtitle
                        Text(
                          'Select your preferred language for the app',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 4.h),

                        // Language Options
                        ..._languages.map((language) {
                          final isSelected =
                              _selectedLanguage == language['code'];

                          return Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: _LanguageOptionCard(
                              languageName: language['name'] as String,
                              displayName: language['displayName'] as String,
                              iconName: language['icon'] as String,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedLanguage =
                                  language['code'] as String;
                                });
                              },
                            ),
                          );
                        }),

                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),

                // Continue Button
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _selectedLanguage != null && !_isLoading
                          ? _saveLanguageAndContinue
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        disabledBackgroundColor: theme.colorScheme.onSurface
                            .withValues(alpha: 0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _getContinueButtonText(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _selectedLanguage != null
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface.withValues(
                            alpha: 0.38,
                          ),
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: theme.colorScheme.surface.withValues(alpha: 0.7),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Language Option Card Widget
class _LanguageOptionCard extends StatelessWidget {
  final String languageName;
  final String displayName;
  final String iconName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionCard({
    required this.languageName,
    required this.displayName,
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Language Icon
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: iconName,
                    size: 6.w,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Language Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      languageName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Checkmark
              if (isSelected)
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'check',
                      size: 5.w,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
