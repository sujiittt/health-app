import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/health_assessment_results_screen/health_assessment_results_screen.dart';
import '../presentation/health_assessment_questions_screen/health_assessment_questions_screen.dart';
import '../presentation/symptoms_selection_screen/symptoms_selection_screen.dart';
import '../presentation/language_selection_screen/language_selection_screen.dart';
import '../presentation/nearby_government_hospitals_screen/nearby_government_hospitals_screen.dart';
import '../presentation/tell_us_more_screen/tell_us_more_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String healthAssessmentResults =
      '/health-assessment-results-screen';
  static const String healthAssessmentQuestions =
      '/health-assessment-questions-screen';
  static const String symptomsSelection = '/symptoms-selection-screen';
  static const String languageSelection = '/language-selection-screen';
  static const String nearbyGovernmentHospitals =
      '/nearby-government-hospitals-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    healthAssessmentResults: (context) => const HealthAssessmentResultsScreen(),
    healthAssessmentQuestions: (context) => HealthAssessmentQuestionsScreen(
      selectedSymptoms:
      (ModalRoute.of(context)?.settings.arguments
      as Map<String, dynamic>?)?['selectedSymptoms']
      as List<String>? ??
          [],
    ),
    symptomsSelection: (context) => const SymptomsSelectionScreen(),
    languageSelection: (context) => const LanguageSelectionScreen(),
    nearbyGovernmentHospitals: (context) =>
        const NearbyGovernmentHospitalsScreen(),
    '/tell-us-more-screen': (context) => const TellUsMoreScreen(),
    // TODO: Add your other routes here
  };
}
