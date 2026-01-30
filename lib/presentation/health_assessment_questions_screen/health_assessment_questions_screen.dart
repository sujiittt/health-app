import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import '../../services/localization_service.dart';
import './widgets/navigation_buttons_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/question_card_widget.dart';

class HealthAssessmentQuestionsScreen extends StatefulWidget {
  final List<String> selectedSymptoms;

  const HealthAssessmentQuestionsScreen({
    super.key,
    required this.selectedSymptoms,
  });

  @override
  State<HealthAssessmentQuestionsScreen> createState() =>
      _HealthAssessmentQuestionsScreenState();
}

class _HealthAssessmentQuestionsScreenState
    extends State<HealthAssessmentQuestionsScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, bool> _answers = {};
  bool _isLoading = false;
  bool _canNavigate = true;
  
  final List<String> _staticQuestions = [
    'Is your symptom severe or getting worse?',
    'Have you had this symptom for more than 3 days?',
    'Is the symptom affecting your daily activities?',
    'Do you have any other health conditions?',
    'Are you taking any medications currently?',
  ];

  @override
  void initState() {
    super.initState();
    LocalizationService().currentLanguage.addListener(_onLanguageChange);
  }
  
  @override
  void dispose() {
    LocalizationService().currentLanguage.removeListener(_onLanguageChange);
    super.dispose();
  }
  
  void _onLanguageChange() {
    setState(() {});
  }

  // Helper to translate questions and UI text
  String _t(String text) => LocalizationService().translateSync(text);

  List<String> get _questions => _staticQuestions.map((q) => _t(q)).toList();

  void _handleAnswerSelection(bool answer) {
    if (!_canNavigate) return;

    HapticFeedback.lightImpact();

    setState(() {
      _answers[_currentQuestionIndex] = answer;
    });
  }

  void _handlePrevious() {
    if (!_canNavigate || _currentQuestionIndex == 0) return;

    HapticFeedback.lightImpact();

    setState(() {
      _currentQuestionIndex--;
    });
  }

  void _handleNext() {
    if (!_canNavigate ||
        _currentQuestionIndex >= _questions.length - 1 ||
        _answers[_currentQuestionIndex] == null) {
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _canNavigate = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentQuestionIndex++;
          _canNavigate = true;
        });
      }
    });
  }

  bool _isNavigating = false;

  Future<void> _handleGetResults() async {
    if (_answers[_currentQuestionIndex] == null || _isNavigating) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = true;
      _isNavigating = true;
    });

    // Removed artificial 2s delay for instant responsiveness

    final int yesCount = _answers.values
        .where((answer) => answer == true)
        .length;
    final int totalQuestions = _questions.length;
    final double riskPercentage = (yesCount / totalQuestions) * 100;

    String riskLevel;
    if (riskPercentage <= 40) {
      riskLevel = 'low';
    } else if (riskPercentage <= 70) {
      riskLevel = 'medium';
    } else {
      riskLevel = 'high';
    }

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
      '/health-assessment-results-screen',
      arguments: {
        'riskLevel': riskLevel,
        'symptoms': widget.selectedSymptoms,
        'answers': _answers,
        // Pass more context if needed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(title: _t('Health Assessment'), showBackButton: true),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: _t('Health Assessment'), showBackButton: true),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark
                    ? const Color(0xFF66BB6A)
                    : const Color(0xFF4CAF50),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _t('Calculating your results...'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 14.sp,
                color: isDark
                    ? const Color(0xFFB0B0B0)
                    : const Color(0xFF757575),
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          ProgressIndicatorWidget(
            currentQuestion: _currentQuestionIndex + 1,
            totalQuestions: _questions.length,
            progressText: _t('Question'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  QuestionCardWidget(
                    question: _questions[_currentQuestionIndex],
                    selectedAnswer: _answers[_currentQuestionIndex],
                    onAnswerSelected: _handleAnswerSelection,
                    yesText: _t('Yes'),
                    noText: _t('No'),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
          NavigationButtonsWidget(
            showPrevious: _currentQuestionIndex > 0,
            showNext: _currentQuestionIndex < _questions.length - 1,
            showGetResults:
            _currentQuestionIndex == _questions.length - 1,
            onPreviousTap: _handlePrevious,
            onNextTap: _handleNext,
            onGetResultsTap: _handleGetResults,
            previousText: _t('Previous'),
            nextText: _t('Next'),
            getResultsText: _t('Get Results'),
            isNextEnabled: _answers[_currentQuestionIndex] != null,
          ),
        ],
      ),
    );
  }
}
