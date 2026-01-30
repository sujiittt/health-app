import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
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
  String _selectedLanguage = 'English';
  bool _isLoading = false;
  bool _canNavigate = true;

  final Map<String, Map<String, dynamic>> _translations = {
    'English': {
      'title': 'Health Assessment',
      'progressText': 'Question',
      'previousButton': 'Previous',
      'nextButton': 'Next',
      'getResultsButton': 'Get Results',
      'yesButton': 'Yes',
      'noButton': 'No',
      'loadingMessage': 'Calculating your results...',
      'questions': [
        'Is your symptom severe or getting worse?',
        'Have you had this symptom for more than 3 days?',
        'Is the symptom affecting your daily activities?',
        'Do you have any other health conditions?',
        'Are you taking any medications currently?',
      ],
    },
    'Hindi': {
      'title': 'स्वास्थ्य मूल्यांकन',
      'progressText': 'प्रश्न',
      'previousButton': 'पिछला',
      'nextButton': 'अगला',
      'getResultsButton': 'परिणाम देखें',
      'yesButton': 'हाँ',
      'noButton': 'नहीं',
      'loadingMessage': 'आपके परिणाम की गणना की जा रही है...',
      'questions': [
        'क्या आपका लक्षण गंभीर है या बिगड़ रहा है?',
        'क्या आपको यह लक्षण 3 दिनों से अधिक समय से है?',
        'क्या लक्षण आपकी दैनिक गतिविधियों को प्रभावित कर रहा है?',
        'क्या आपको कोई अन्य स्वास्थ्य समस्या है?',
        'क्या आप वर्तमान में कोई दवा ले रहे हैं?',
      ],
    },
    'Marathi': {
      'title': 'आरोग्य मूल्यांकन',
      'progressText': 'प्रश्न',
      'previousButton': 'मागील',
      'nextButton': 'पुढील',
      'getResultsButton': 'निकाल पहा',
      'yesButton': 'होय',
      'noButton': 'नाही',
      'loadingMessage': 'तुमचे निकाल मोजले जात आहेत...',
      'questions': [
        'तुमचे लक्षण गंभीर आहे किंवा वाढत आहे का?',
        'तुम्हाला हे लक्षण 3 दिवसांपेक्षा जास्त काळ आहे का?',
        'लक्षण तुमच्या दैनंदिन क्रियाकलापांवर परिणाम करत आहे का?',
        'तुम्हाला इतर कोणतीही आरोग्य समस्या आहे का?',
        'तुम्ही सध्या कोणतीही औषधे घेत आहात का?',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  List<String> get _questions =>
      (_translations[_selectedLanguage]?['questions'] as List<dynamic>?)
          ?.cast<String>() ??
          [];

  String _getText(String key) {
    return _translations[_selectedLanguage]?[key] as String? ?? '';
  }

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

  Future<void> _handleGetResults() async {
    if (_answers[_currentQuestionIndex] == null) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

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

    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
      '/health-assessment-results-screen',
      arguments: {
        'riskLevel': riskLevel,
        'symptoms': widget.selectedSymptoms,
        'answers': _answers,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(title: _getText('title'), showBackButton: true),
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
      appBar: CustomAppBar(title: _getText('title'), showBackButton: true),
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
              _getText('loadingMessage'),
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
            progressText: _getText('progressText'),
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
                    yesText: _getText('yesButton'),
                    noText: _getText('noButton'),
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
            previousText: _getText('previousButton'),
            nextText: _getText('nextButton'),
            getResultsText: _getText('getResultsButton'),
            isNextEnabled: _answers[_currentQuestionIndex] != null,
          ),
        ],
      ),
    );
  }
}
