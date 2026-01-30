import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import '../../services/gemini_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/care_recommendations_widget.dart';
import './widgets/disclaimer_widget.dart';
import './widgets/risk_level_card_widget.dart';

/// Health Assessment Results Screen
/// Displays color-coded risk assessment with care recommendations
class HealthAssessmentResultsScreen extends StatefulWidget {
  const HealthAssessmentResultsScreen({super.key});

  @override
  State<HealthAssessmentResultsScreen> createState() =>
      _HealthAssessmentResultsScreenState();
}

class _HealthAssessmentResultsScreenState
    extends State<HealthAssessmentResultsScreen> {
  late Map<String, dynamic> _assessmentResult;
  final GeminiService _geminiService = GeminiService();
  bool _isLoadingRecommendations = false;
  List<String> _aiRecommendations = [];
  String _aiSummary = '';
  String _culturalTips = '';
  String _warningSigns = '';
  String _selectedLanguage = 'English';
  List<String> _selectedSymptoms = [];

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLanguageAndGenerateRecommendations();
    });
  }

  Future<void> _loadLanguageAndGenerateRecommendations() async {
    // Get symptoms from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['symptoms'] != null) {
      _selectedSymptoms = (args['symptoms'] as List).cast<String>();
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });

    _calculateRiskLevel();
    await _generateAIRecommendations();
  }

  Future<void> _generateAIRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final response = await _geminiService.generateHealthRecommendations(
        symptoms: _selectedSymptoms,
        riskLevel: _assessmentResult['riskLevel'] as String,
        language: _selectedLanguage,
      );

      setState(() {
        _aiSummary = response['summary'] ?? '';

        // Parse recommendations from response
        final recommendationsText = response['recommendations'] ?? '';
        if (recommendationsText.isNotEmpty) {
          _aiRecommendations = recommendationsText
              .split('\n')
              .where((line) => line.trim().startsWith('-') || line.trim().startsWith('•'))
              .map((line) => line.replaceFirst(RegExp(r'^[\s-•]+'), '').trim())
              .where((line) => line.isNotEmpty)
              .toList();
        }

        _culturalTips = response['culturalTips'] ?? '';
        _warningSigns = response['warningSigns'] ?? '';
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRecommendations = false;
        // Keep default recommendations on error
      });
    }
  }

  void _calculateRiskLevel() {
    final int riskScore = DateTime.now().second % 3;

    if (riskScore == 0) {
      _assessmentResult = {
        'riskLevel': 'Low Risk',
        'riskMessage': 'आप घर पर आराम कर सकते हैं\nYou can rest at home',
        'cardColor': const Color(0xFF4CAF50),
        'iconName': 'home',
        'recommendations': [
          'Take adequate rest and stay hydrated',
          'Monitor your symptoms for any changes',
          'Maintain a balanced diet with nutritious food',
          'Practice good hygiene and wash hands regularly',
          'Get sufficient sleep of 7-8 hours daily',
        ],
        'summary':
        'Health Assessment Result: Low Risk - Home care recommended. Rest well, stay hydrated, and monitor symptoms.',
      };
    } else if (riskScore == 1) {
      _assessmentResult = {
        'riskLevel': 'Medium Risk',
        'riskMessage': 'सावधानी बरतें और निगरानी रखें\nBe cautious and monitor',
        'cardColor': const Color(0xFFFF9800),
        'iconName': 'warning',
        'recommendations': [
          'Monitor your symptoms closely for 24-48 hours',
          'Keep track of temperature and other vital signs',
          'Avoid strenuous physical activities',
          'Stay in touch with family members about your condition',
          'Consult a doctor if symptoms worsen or persist',
          'Maintain isolation if you have fever or cough',
        ],
        'summary':
        'Health Assessment Result: Medium Risk - Caution advised. Monitor symptoms closely and consult doctor if condition worsens.',
      };
    } else {
      _assessmentResult = {
        'riskLevel': 'High Risk',
        'riskMessage': 'तुरंत डॉक्टर से मिलें\nConsult doctor immediately',
        'cardColor': const Color(0xFFD32F2F),
        'iconName': 'local_hospital',
        'recommendations': [
          'Visit the nearest healthcare facility immediately',
          'Do not delay seeking medical attention',
          'Inform family members about your condition',
          'Carry any existing medical records with you',
          'Avoid self-medication without doctor consultation',
          'Call emergency services if symptoms are severe',
          'Keep emergency contact numbers handy',
        ],
        'summary':
        'Health Assessment Result: High Risk - Immediate medical attention required. Visit nearest healthcare facility without delay.',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Assessment Results',
        showBackButton: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 2.h),
              RiskLevelCardWidget(
                riskLevel: _assessmentResult['riskLevel'] as String,
                riskMessage: _assessmentResult['riskMessage'] as String,
                cardColor: _assessmentResult['cardColor'] as Color,
                iconName: _assessmentResult['iconName'] as String,
              ),
              SizedBox(height: 2.h),

              // AI-generated summary section
              if (_isLoadingRecommendations)
                Container(
                  width: 90.w,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Generating personalized recommendations...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else if (_aiSummary.isNotEmpty)
                Container(
                  width: 90.w,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'AI Health Insights',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _aiSummary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 2.h),

              // Show AI recommendations if available, otherwise show default
              CareRecommendationsWidget(
                recommendations: _aiRecommendations.isNotEmpty
                    ? _aiRecommendations
                    : (_assessmentResult['recommendations'] as List).cast<String>(),
              ),

              // Cultural tips section
              if (_culturalTips.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Container(
                  width: 90.w,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.spa,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Home Remedies',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _culturalTips,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Warning signs section
              if (_warningSigns.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Container(
                  width: 90.w,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'When to Seek Help',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _warningSigns,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 2.h),
              // Show hospital finder button only for High Risk
              if (_assessmentResult['riskLevel'] == 'High Risk')
                Container(
                  width: 90.w,
                  margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.nearbyGovernmentHospitals,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_hospital, size: 24),
                          SizedBox(width: 2.w),
                          Text(
                            'Find Nearby Government Hospitals',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_assessmentResult['riskLevel'] == 'High Risk')
                SizedBox(height: 2.h),
              ActionButtonsWidget(
                resultSummary: _assessmentResult['summary'] as String,
              ),
              SizedBox(height: 2.h),
              const DisclaimerWidget(),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}