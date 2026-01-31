import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/utils/emergency_helper.dart'; // Import Helper
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/symptoms_grid_widget.dart';
import '../../widgets/translated_text.dart';
import '../../services/localization_service.dart';

/// Symptoms Selection Screen - Multi-select symptom checker interface
/// Enables users to identify health concerns through visual symptom cards
/// Implements large touch targets and clear visual feedback for rural users
class SymptomsSelectionScreen extends StatefulWidget {
  const SymptomsSelectionScreen({super.key});

  @override
  State<SymptomsSelectionScreen> createState() =>
      _SymptomsSelectionScreenState();
}

class _SymptomsSelectionScreenState extends State<SymptomsSelectionScreen> {
  // Selected symptoms tracking
  final Set<String> _selectedSymptoms = {};

  // Symptom data with culturally appropriate icons
  final List<Map<String, dynamic>> _symptoms = [
    {
      'id': 'fever',
      'name': 'Fever',
      'icon': 'thermostat',
      'nameHindi': 'बुखार',
      'nameMarathi': 'ताप',
    },
    {
      'id': 'cold_cough',
      'name': 'Cold/Cough',
      'icon': 'air',
      'nameHindi': 'सर्दी/खांसी',
      'nameMarathi': 'सर्दी/खोकला',
    },
    {
      'id': 'headache',
      'name': 'Headache',
      'icon': 'psychology',
      'nameHindi': 'सिरदर्द',
      'nameMarathi': 'डोकेदुखी',
    },
    {
      'id': 'stomach_pain',
      'name': 'Stomach Pain',
      'icon': 'emergency',
      'nameHindi': 'पेट दर्द',
      'nameMarathi': 'पोटदुखी',
    },
    {
      'id': 'injury',
      'name': 'Injury',
      'icon': 'healing',
      'nameHindi': 'चोट',
      'nameMarathi': 'दुखापत',
    },
    {
      'id': 'breathing_problem',
      'name': 'Breathing Problem',
      'icon': 'air',
      'nameHindi': 'सांस लेने में तकलीफ',
      'nameMarathi': 'श्वास घेण्यात अडचण',
    },
  ];

  void _toggleSymptom(String symptomId) {
    setState(() {
      if (_selectedSymptoms.contains(symptomId)) {
        _selectedSymptoms.remove(symptomId);
      } else {
        _selectedSymptoms.add(symptomId);
      }
    });
  }

  void _navigateToQuestions() {
    if (_selectedSymptoms.isEmpty) return;

    Navigator.of(context, rootNavigator: true).pushNamed(
      '/health-assessment-questions-screen',
      arguments: {'selectedSymptoms': _selectedSymptoms.toList()},
    );
  }

  String _getTitle(String langCode) {
    switch (langCode) {
      case 'hi':
        return 'अपने लक्षण चुनें';
      case 'mr':
        return 'आपली लक्षणे निवडा';
      default:
        return 'Select Your Symptoms';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService().currentLanguage,
      builder: (context, langCode, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: _getTitle(langCode),
            showBackButton: true,
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/language-selection-screen');
                },
                icon: const Icon(Icons.language),
                color: theme.colorScheme.primary,
                tooltip: 'Change Language',
              ),
              IconButton(
                onPressed: () => EmergencyHelper.showEmergencyDialog(context),
                icon: const Icon(Icons.phone_in_talk),
                color: const Color(0xFFD32F2F),
                iconSize: 28,
                tooltip: 'Emergency Helpline (108)',
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
          // Body contains Header + Grid
          body: SafeArea(
            child: Column(
              children: [
                // Top Header Area
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    children: [
                       TrText(
                        'Tap on the symptoms you are experiencing',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? const Color(0xFFB0B0B0)
                              : const Color(0xFF757575),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.5.h),
                      
                      // Status Area
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 5.h),
                        child: Center(
                          child: _selectedSymptoms.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1E1E)
                                      : theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0x1FFFFFFF)
                                        : theme.colorScheme.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'info_outline',
                                      size: 24,
                                      color: theme.colorScheme.primary,
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: TrText(
                                        'Please select at least one symptom to continue',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: isDark
                                              ? const Color(0xFFB0B0B0)
                                              : const Color(0xFF757575),
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'check_circle',
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      '${_selectedSymptoms.length} symptom${_selectedSymptoms.length > 1 ? 's' : ''} selected',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expanded Grid Area
                Expanded(
                  child: Center(
                    child: SymptomsGridWidget(
                      symptoms: _symptoms,
                      selectedSymptoms: _selectedSymptoms,
                      onSymptomTap: _toggleSymptom,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed Bottom Action Area (Solved Overflow)
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0x1FFFFFFF)
                      : const Color(0x1F000000),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedSymptoms.isEmpty
                          ? null
                          : _navigateToQuestions,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        backgroundColor: _selectedSymptoms.isEmpty
                            ? (isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF5F5F5))
                            : theme.colorScheme.primary,
                        foregroundColor: _selectedSymptoms.isEmpty
                            ? (isDark
                                ? const Color(0xFF757575)
                                : const Color(0xFFB0B0B0))
                            : (isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _selectedSymptoms.isEmpty ? 0 : 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TrText(
                            'Next',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: _selectedSymptoms.isEmpty
                                  ? null 
                                  : Colors.white,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 22,
                            color: _selectedSymptoms.isEmpty
                            ? null 
                            : Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 2.h),

                  // "I Have a Different Problem" Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.1),
                          theme.colorScheme.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/tell-us-more-screen');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: Center(
                            child: TrText(
                              'I Have a Different Problem',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
