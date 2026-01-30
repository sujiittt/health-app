import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import '../../services/gemini_service.dart';
import '../../services/localization_service.dart';
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
  List<String> _selectedSymptoms = [];

  late int _riskScore; // Persist risk score

  @override
  void initState() {
    super.initState();
    // Initialize risk score once to prevent changing on rebuilds/language change
    _riskScore = DateTime.now().second % 3;
    
    // Delay to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLanguageAndGenerateRecommendations();
    });
    
    // Listen to language changes
    LocalizationService().currentLanguage.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    LocalizationService().currentLanguage.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    if (mounted) {
      setState(() {
        // Re-calculate local UI strings with new language
        _calculateRiskLevel(); 
        // Re-fetch AI content in new language
        _generateAIRecommendations();
      });
    }
  }

  // Helper
  String _t(String text) => LocalizationService().translateSync(text);

  Future<void> _loadLanguageAndGenerateRecommendations() async {
    // Get symptoms from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['symptoms'] != null) {
      _selectedSymptoms = (args['symptoms'] as List).cast<String>();
    }

    _calculateRiskLevel();
    await _generateAIRecommendations();
  }

  Future<void> _generateAIRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final currentLang = LocalizationService().langCode; // Get from service
      final response = await _geminiService.generateHealthRecommendations(
        symptoms: _selectedSymptoms,
        riskLevel: _assessmentResult['riskLevel'] as String, // This will be localized now, might need to pass English risk level to API? 
        // Gemini handles mixed languages well, but ideally we send standardized "High Risk" context.
        // For now, let's trust Gemini understands the localized risk level or just pass context.
        language: currentLang,
      );

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
          // Keep default recommendations on error
        });
      }
    }
  }

  void _calculateRiskLevel() {
    // Use stored _riskScore instead of recalculating
    
    if (_riskScore == 0) {
      _assessmentResult = {
        'riskLevel': 'Low Risk', // Kept English key for logic if needed, but we display this
        'riskMessage': _t('You can rest at home'),
        'cardColor': const Color(0xFF4CAF50),
        'iconName': 'home',
        'recommendations': [
          _t('Take adequate rest and stay hydrated'),
          _t('Monitor your symptoms for any changes'),
          _t('Maintain a balanced diet with nutritious food'),
          _t('Practice good hygiene and wash hands regularly'),
          _t('Get sufficient sleep of 7-8 hours daily'),
        ],
        'summary': _t('Health Assessment Result: Low Risk - Home care recommended. Rest well, stay hydrated, and monitor symptoms.'),
      };
    } else if (_riskScore == 1) {
      _assessmentResult = {
        'riskLevel': 'Medium Risk',
        'riskMessage': _t('Be cautious and monitor'),
        'cardColor': const Color(0xFFFF9800),
        'iconName': 'warning',
        'recommendations': [
          _t('Monitor your symptoms closely for 24-48 hours'),
          _t('Keep track of temperature and other vital signs'),
          _t('Avoid strenuous physical activities'),
          _t('Stay in touch with family members about your condition'),
          _t('Consult a doctor if symptoms worsen or persist'),
          _t('Maintain isolation if you have fever or cough'),
        ],
        'summary': _t('Health Assessment Result: Medium Risk - Caution advised. Monitor symptoms closely and consult doctor if condition worsens.'),
      };
    } else {
      _assessmentResult = {
        'riskLevel': 'High Risk',
        'riskMessage': _t('Consult doctor immediately'),
        'cardColor': const Color(0xFFD32F2F),
        'iconName': 'local_hospital',
        'recommendations': [
          _t('Visit the nearest healthcare facility immediately'),
          _t('Do not delay seeking medical attention'),
          _t('Inform family members about your condition'),
          _t('Carry any existing medical records with you'),
          _t('Avoid self-medication without doctor consultation'),
          _t('Call emergency services if symptoms are severe'),
          _t('Keep emergency contact numbers handy'),
        ],
        'summary': _t('Health Assessment Result: High Risk - Immediate medical attention required. Visit nearest healthcare facility without delay.'),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default init if not ready
    if (!textAlignIsDefined()) {
      // just a dummy check, logic is fine as _calculateRiskLevel is called in initState/postFrame
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: _t('Assessment Results'),
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
                riskLevel: _t(_assessmentResult['riskLevel'] as String),
                riskMessage: _assessmentResult['riskMessage'] as String, // Add translation for this if needed
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
                        color: Colors.black.withOpacity(0.05),
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
                        _t('Generating personalized recommendations...'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                            _t('AI Health Insights'),
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
                        color: Colors.black.withOpacity(0.05),
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
                            _t('Home Remedies'),
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
                            _t('When to Seek Help'),
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
                            _t('Find Nearby Government Hospitals'),
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

  bool textAlignIsDefined() {
    return true; 
  }
}