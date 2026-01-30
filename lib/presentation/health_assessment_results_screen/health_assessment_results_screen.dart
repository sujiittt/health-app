import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import '../../services/gemini_service.dart';
import '../../services/localization_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/ai_response_viewer.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/care_recommendations_widget.dart'; // Still used? Likely not if AiResponseViewer handles it.
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
  final GeminiService _geminiService = GeminiService();
  
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _apiData;

  // Data to populate UI
  String _riskLevel = 'Unknown';
  String _riskMessage = '';
  Color _cardColor = Colors.grey;
  String _iconName = 'help_outline';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAssessment();
    });
    LocalizationService().currentLanguage.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    LocalizationService().currentLanguage.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    if (mounted) {
      _fetchAssessment(); // Reload everything on language change
    }
  }

  String _t(String text) => LocalizationService().translateSync(text);

  bool _isFetching = false;

  Future<void> _fetchAssessment() async {
    if (_isFetching) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final symptoms = args?['symptoms'] as List<String>? ?? [];
    
    final age = args?['age'] as String? ?? '30';
    final gender = args?['gender'] as String? ?? 'Other';
    final description = args?['description'] as String?;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isFetching = true;
    });

    try {
      final currentLang = LocalizationService().langCode;
      
      final data = await _geminiService.generateHealthRecommendations(
        symptoms: symptoms,
        riskLevel: "Pending", 
        age: age,
        gender: gender,
        description: description,
        language: currentLang,
      );

      if (!mounted) return;

      _processApiResponse(data);

      setState(() {
        _isLoading = false;
        _apiData = data;
        _isFetching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _isFetching = false;
      });
    } finally {
      // Safety net
      if (mounted && _isFetching) {
         setState(() => _isFetching = false);
      }
    }
  }

  void _processApiResponse(Map<String, dynamic> data) {
    // 1. Extract Risk Level for Top Card
    _riskLevel = data['riskLevel'] ?? 'Medium Risk';
    
    // 2. Map Risk to UI Properties (Colors, Icons, Messages)
    _mapRiskToUI(_riskLevel);
  }

  void _mapRiskToUI(String riskLevel) {
    // Normalize string
    final lowerRisk = riskLevel.toLowerCase();
    
    if (lowerRisk.contains('high')) {
      _riskMessage = _t('Consult doctor immediately');
      _cardColor = const Color(0xFFD32F2F); // Red
      _iconName = 'local_hospital';
    } else if (lowerRisk.contains('low')) {
      _riskMessage = _t('You can rest at home');
      _cardColor = const Color(0xFF4CAF50); // Green
      _iconName = 'home';
    } else {
      // Medium or default
      _riskMessage = _t('Be cautious and monitor');
      _cardColor = const Color(0xFFFF9800); // Orange
      _iconName = 'warning';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: _t('Assessment Results'),
        showBackButton: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(theme)
            : _errorMessage != null
                ? _buildErrorState(theme)
                : _buildContent(theme),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 3.h),
          Text(
            _t('Analyzing symptoms...'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _t('Connecting to health server...'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 20.w, color: theme.colorScheme.error),
            SizedBox(height: 3.h),
            Text(
              _t('Failed to load assessment'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage ?? _t('Unknown error occurred'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: _fetchAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              ),
              child: Text(_t('Retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 2.h),
          
          // 1. Dynamic Risk Card (UI specific to this screen)
          RiskLevelCardWidget(
            riskLevel: _riskLevel, // Display as returned by API
            riskMessage: _riskMessage,
            cardColor: _cardColor,
            iconName: _iconName,
          ),
          SizedBox(height: 2.h),

          // 2. AI Content (Standardized)
          if (_apiData != null)
            AiResponseViewer(
              data: _apiData!,
            ),
          
          SizedBox(height: 2.h),

          // 3. Hospital Button (Only for High Risk)
          if (_riskLevel.toLowerCase().contains('high'))
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

          if (_riskLevel.toLowerCase().contains('high'))
            SizedBox(height: 2.h),

          // 4. Action Buttons (Share/Save - uses summary if available)
          if (_apiData != null && _apiData!['summary'] != null)
             ActionButtonsWidget(
               resultSummary: _apiData!['summary'] as String? ?? '',
             ),
          
          SizedBox(height: 2.h),
          const DisclaimerWidget(),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }
}