import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  GenerativeModel? _model;
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  factory GeminiService() => _instance;

  GeminiService._internal() {
    _initializeService();
  }

  void _initializeService() {
    if (apiKey.isEmpty) {
      print('Warning: GEMINI_API_KEY is missing. Using mock data.');
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
  }

  Future<Map<String, String>> generateHealthRecommendations({
    required List<String> symptoms,
    required String riskLevel,
    required String language,
  }) async {
    // Return mock data if service is not initialized (missing API key)
    if (_model == null) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      return _getMockData(language);
    }

    try {
      final languageMap = {
        'English': 'English',
        'Hindi': 'Hindi (हिंदी)',
        'Marathi': 'Marathi (मराठी)',
      };

      final targetLanguage = languageMap[language] ?? 'English';
      final symptomsText = symptoms.join(', ');

      final prompt =
      '''
You are a culturally sensitive health advisor for rural India. Generate personalized health recommendations based on:

Symptoms: $symptomsText
Risk Level: $riskLevel
Language: $targetLanguage

Provide recommendations in the following format:
1. A brief summary (2-3 sentences) explaining the condition in simple terms
2. 5-7 practical, actionable recommendations suitable for rural settings
3. Cultural considerations (home remedies, dietary advice common in Indian households)
4. When to seek immediate medical attention

IMPORTANT:
- Write ENTIRELY in $targetLanguage
- Use simple, clear language that rural populations can understand
- Include culturally appropriate advice (e.g., mention tulsi, ginger, turmeric for home remedies)
- Be empathetic and reassuring
- For High Risk: emphasize urgency but avoid panic
- For Medium Risk: balance caution with practical monitoring advice
- For Low Risk: provide comfort while encouraging basic self-care

Format your response as:
SUMMARY: [your summary here]
RECOMMENDATIONS:
- [recommendation 1]
- [recommendation 2]
...
CULTURAL_TIPS: [cultural advice]
WARNING_SIGNS: [when to seek help]
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw GeminiException('No response generated from Gemini API');
      }

      return _parseResponse(response.text!);
    } catch (e) {
      if (e is GenerativeAIException) {
        throw GeminiException('Gemini API Error: ${e.message}');
      }
      throw GeminiException('Failed to generate recommendations: $e');
    }
  }

  /// Generates general guidance for "Tell Us More" screen
  Future<Map<String, String>> generateGeneralGuidance({
    required String gender,
    required String age,
    required String description,
    required List<String> selectedChips,
    String language = 'English',
  }) async {
    if (_model == null) {
      await Future.delayed(const Duration(seconds: 1));
      return _getMockData(language);
    }

    try {
      // Basic language map (can be expanded)
      final languageMap = {
        'English': 'English',
        'Hindi': 'Hindi',
        'Marathi': 'Marathi',
      };
      final targetLanguage = languageMap[language] ?? 'English';

      final prompt = '''
You are a preliminary health guide for rural India. A user has reported a problem.
User Details:
- Gender: $gender
- Age: $age
- Additional Symptoms: ${selectedChips.join(', ')}
- Problem Description: "$description"

Provide safe, non-diagnostic guidance in $targetLanguage.
Focus on:
1. Reassurance and calm advice.
2. Basic home care or immediate steps.
3. Clear warning signs indicating when to see a doctor or call 108 (Emergency).

IMPORTANT:
- Do NOT provide a medical diagnosis.
- Use simple, easy-to-understand language.
- Structure with clear headings.

Format your response strictly as:
SUMMARY: [Reassurance and brief understanding of the issue]
ADVICE: 
- [Step 1]
- [Step 2]
WARNING_SIGNS: [Specific signs to go to hospital immediately]
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
         throw GeminiException('No response generated.');
      }

      return _parseGeneralResponse(response.text!);

    } catch (e) {
       if (e is GenerativeAIException) {
        throw GeminiException('Gemini API Error: ${e.message}');
      }
      throw GeminiException('Failed to generate guidance: $e');
    }
  }

  Map<String, String> _parseGeneralResponse(String text) {
     final result = <String, String>{};
     // Simple parsing based on the requested format
     // Using regex similar to _parseResponse but adapted for the new keys
     
     // Summary
     var match = RegExp(r'SUMMARY:\s*(.+?)(?=\n\n|ADVICE:)', dotAll: true).firstMatch(text);
     result['summary'] = match?.group(1)?.trim() ?? '';

     // Advice
     match = RegExp(r'ADVICE:\s*(.+?)(?=\n\n|WARNING_SIGNS:)', dotAll: true).firstMatch(text);
     result['advice'] = match?.group(1)?.trim() ?? '';

     // Warning Signs
     match = RegExp(r'WARNING_SIGNS:\s*(.+?)$', dotAll: true).firstMatch(text);
     result['warningSigns'] = match?.group(1)?.trim() ?? '';

     // Fallback
     if (result['summary']!.isEmpty) {
       result['summary'] = text; // Just show raw text if parse fails
     }
     
     return result;
  }

  Map<String, String> _getMockData(String language) {
    if (language == 'Hindi') {
      return {
        'summary': 'आपके लक्षणों के आधार पर, यह एक सामान्य संक्रमण लग रहा है। चिंता की कोई बात नहीं है, लेकिन आराम करना महत्वपूर्ण है।',
        'recommendations': '- खूब पानी और तरल पदार्थ पिएं।\n- पर्याप्त आराम करें।\n- हल्का और सुपाच्य भोजन लें।\n- बुखार होने पर ठंडे पानी की पट्टियां रखें।',
        'culturalTips': 'तुलसी और अदरक की चाय पीने से राहत मिल सकती है।',
        'warningSigns': 'यदि बुखार 3 दिनों से अधिक रहता है या साँस लेने में तकलीफ होती है, तो तुरंत डॉक्टर से संपर्क करें।',
      };
    } else if (language == 'Marathi') {
      return {
        'summary': 'तुमच्या लक्षणांवरून हे सामान्य संसर्ग असल्याचे दिसते. काळजी करण्याचे कारण नाही, पण आराम करणे महत्त्वाचे आहे.',
        'recommendations': '- भरपूर पाणी आणि द्रव पदार्थ प्या.\n- पुरेशी झोप घ्या.\n- हलके आणि पचायला सोपे अन्न खा.\n- ताप असल्यास कोमट पाण्याने अंग पुसून घ्या.',
        'culturalTips': 'तुळस आणि आले टाकलेला चहा प्यायल्याने आराम मिळू शकतो.',
        'warningSigns': 'जर ताप ३ दिवसांपेक्षा जास्त राहिला किंवा श्वास घेण्यास त्रास होत असेल, तर त्वरित डॉक्टरांचा सल्ला घ्या.',
      };
    } else {
      return {
        'summary': 'Based on your symptoms, this appears to be a mild viral infection. There is usually no cause for alarm, but rest is key to recovery.',
        'recommendations': '- Drink plenty of water and fluids.\n- Get adequate rest and sleep.\n- Eat light, home-cooked meals.\n- Monitor your temperature regularly.',
        'culturalTips': 'Drinking warm turmeric milk (Haldi Doodh) before bed can boost immunity.',
        'warningSigns': 'Seek immediate medical help if you experience difficulty breathing, chest pain, or high fever persisting for more than 3 days.',
      };
    }
  }

  Map<String, String> _parseResponse(String responseText) {
    final result = <String, String>{};

    try {
      // Extract summary
      final summaryMatch = RegExp(
        r'SUMMARY:\s*(.+?)(?=\n\n|RECOMMENDATIONS:)',
        dotAll: true,
      ).firstMatch(responseText);
      result['summary'] = summaryMatch?.group(1)?.trim() ?? '';

      // Extract recommendations
      final recommendationsMatch = RegExp(
        r'RECOMMENDATIONS:\s*(.+?)(?=\n\n|CULTURAL_TIPS:|WARNING_SIGNS:|$)',
        dotAll: true,
      ).firstMatch(responseText);
      result['recommendations'] = recommendationsMatch?.group(1)?.trim() ?? '';

      // Extract cultural tips
      final culturalMatch = RegExp(
        r'CULTURAL_TIPS:\s*(.+?)(?=\n\n|WARNING_SIGNS:|$)',
        dotAll: true,
      ).firstMatch(responseText);
      result['culturalTips'] = culturalMatch?.group(1)?.trim() ?? '';

      // Extract warning signs
      final warningMatch = RegExp(
        r'WARNING_SIGNS:\s*(.+?)$',
        dotAll: true,
      ).firstMatch(responseText);
      result['warningSigns'] = warningMatch?.group(1)?.trim() ?? '';

      // If parsing fails, return the full response as summary
      if (result['summary']!.isEmpty && result['recommendations']!.isEmpty) {
        result['summary'] = responseText;
      }

      return result;
    } catch (e) {
      // Fallback: return full response
      return {
        'summary': responseText,
        'recommendations': '',
        'culturalTips': '',
        'warningSigns': '',
      };
    }
  }

  void dispose() {
    // Cleanup if needed
  }
}

class GeminiException implements Exception {
  final String message;

  GeminiException(this.message);

  @override
  String toString() => 'GeminiException: $message';
}
