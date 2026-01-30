import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/gemini_service.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;

  LocalizationService._internal();

  final ValueNotifier<String> currentLanguage = ValueNotifier<String>('en');
  
  // Cache structure: {'Original Text': {'hi': 'Translated Text', 'mr': 'Translated Text'}}
  final Map<String, Map<String, String>> _translationCache = {};
  
  // Basic static translations for immediate feedback can be added here
  final Map<String, Map<String, String>> _staticCache = {
    'Next': {'hi': 'अगला', 'mr': 'पुढील'},
    'Continue': {'hi': 'जारी रखें', 'mr': 'पुढे जा'},
    'Select Language': {'hi': 'भाषा चुनें', 'mr': 'भाषा निवडा'},
    'Tap on the symptoms you are experiencing': {
      'hi': 'उन लक्षणों पर टैप करें जो आप महसूस कर रहे हैं',
      'mr': 'तुम्हाला जाणवणाऱ्या लक्षणांवर टॅप करा'
    },
    'Please select at least one symptom to continue': {
      'hi': 'जारी रखने के लिए कृपया कम से कम एक लक्षण चुनें',
      'mr': 'पुढे जाण्यासाठी कृपया किमान एक लक्षण निवडा'
    },
    'I Have a Different Problem': {
      'hi': 'मुझे कोई और समस्या है',
      'mr': 'मला दुसरी समस्या आहे'
    },
    'Emergency Helpline': {'hi': 'आपातकालीन हेल्पलाइन', 'mr': 'आपत्कालीन हेल्पलाइन'},
    'Call 108': {'hi': '108 पर कॉल करें', 'mr': '108 ला कॉल करा'},
    'Cancel': {'hi': 'रद्द करें', 'mr': 'रद्द करा'},
    'Gender': {'hi': 'लिंग', 'mr': 'लिंग'},
    'Age': {'hi': 'उम्र', 'mr': 'वय'},
    'Describe your problem': {'hi': 'अपनी समस्या का वर्णन करें', 'mr': 'तुमच्या समस्येचे वर्णन करा'},
    'Get Guidance': {'hi': 'सलाह प्राप्त करें', 'mr': 'मार्गदर्शन मिळवा'},
    'Common Symptoms (Optional)': {
      'hi': 'सामान्य लक्षण (वैकल्पिक)', 
      'mr': 'सामान्य लक्षणे (वैकल्पिक)'
    },
    'Enter age': {'hi': 'उम्र दर्ज करें', 'mr': 'वय प्रविष्ट करा'},
    'Type here regarding what you are feeling...': {
      'hi': 'आप कैसा महसूस कर रहे हैं, यहाँ लिखें...',
      'mr': 'तुम्हाला कसे वाटत आहे ते येथे टाईप करा...'
    },
    'Required': {'hi': 'आवश्यक', 'mr': 'आवश्यक'},
    'Invalid age': {'hi': 'अमान्य उम्र', 'mr': 'अवैध वय'},
    'Please describe your problem': {
      'hi': 'कृपया अपनी समस्या का वर्णन करें',
      'mr': 'कृपया आपल्या समस्येचे वर्णन करा'
    },
    'Male': {'hi': 'पुरुष', 'mr': 'पुरुष'},
    'Female': {'hi': 'महिला', 'mr': 'स्त्री'},
    'Other': {'hi': 'अन्य', 'mr': 'इतर'},
    
    // Chips
    'Pain': {'hi': 'दर्द', 'mr': 'वेदना'},
    'Dizziness': {'hi': 'चक्कर आना', 'mr': 'चक्कर येणे'},
    'Weakness': {'hi': 'कमज़ोरी', 'mr': 'अशक्तपणा'},
    'Vomiting': {'hi': 'उल्टी', 'mr': 'उलटी'},
    'Injury': {'hi': 'चोट', 'mr': 'दुखापत'},
    'Breathing Issue': {'hi': 'सांस लेने में समस्या', 'mr': 'श्वास घेण्यास त्रास'},
    
    // Health Assessment
    'Health Assessment': {'hi': 'स्वास्थ्य मूल्यांकन', 'mr': 'आरोग्य मूल्यांकन'},
    'Question': {'hi': 'प्रश्न', 'mr': 'प्रश्न'},
    'Previous': {'hi': 'पिछला', 'mr': 'मागील'},
    'Get Results': {'hi': 'परिणाम देखें', 'mr': 'निकाल पहा'},
    'Yes': {'hi': 'हाँ', 'mr': 'होय'},
    'No': {'hi': 'नहीं', 'mr': 'नाही'},
    'Calculating your results...': {
      'hi': 'आपके परिणाम की गणना की जा रही है...',
      'mr': 'तुमचे निकाल मोजले जात आहेत...'
    },
    // Questions (If strictly static, good to optimize here)
    'Is your symptom severe or getting worse?': {
      'hi': 'क्या आपका लक्षण गंभीर है या बिगड़ रहा है?',
      'mr': 'तुमचे लक्षण गंभीर आहे किंवा वाढत आहे का?'
    },
    'Have you had this symptom for more than 3 days?': {
      'hi': 'क्या आपको यह लक्षण 3 दिनों से अधिक समय से है?',
      'mr': 'तुम्हाला हे लक्षण 3 दिवसांपेक्षा जास्त काळ आहे का?'
    },
    'Is the symptom affecting your daily activities?': {
      'hi': 'क्या लक्षण आपकी दैनिक गतिविधियों को प्रभावित कर रहा है?',
      'mr': 'लक्षण तुमच्या दैनंदिन क्रियाकलापांवर परिणाम करत आहे का?'
    },
    'Do you have any other health conditions?': {
      'hi': 'क्या आपको कोई अन्य स्वास्थ्य समस्या है?',
      'mr': 'तुम्हाला इतर कोणतीही आरोग्य समस्या आहे का?'
    },
    'Are you taking any medications currently?': {
      'hi': 'क्या आप वर्तमान में कोई दवा ले रहे हैं?',
      'mr': 'तुम्ही सध्या कोणतीही औषधे घेत आहात का?'
    },

    // Result Screen
    'Assessment Results': {'hi': 'मूल्यांकन परिणाम', 'mr': 'मूल्यांकन निकाल'},
    'Low Risk': {'hi': 'कम जोखिम', 'mr': 'कमी धोका'},
    'Medium Risk': {'hi': 'मध्यम जोखिम', 'mr': 'मध्यम धोका'},
    'High Risk': {'hi': 'उच्च जोखिम', 'mr': 'उच्च धोका'},
    'AI Health Insights': {'hi': 'एआई स्वास्थ्य जानकारी', 'mr': 'एआय आरोग्य माहिती'},
    'Home Remedies': {'hi': 'घरेलू उपचार', 'mr': 'घरगुती उपाय'},
    'When to Seek Help': {'hi': 'मदद कब लें', 'mr': 'मदत कधी घ्यावी'},
    'Find Nearby Government Hospitals': {
      'hi': 'नज़दीकी सरकारी अस्पताल खोजें',
      'mr': 'जवळचे सरकारी रुग्णालय शोधा'
    },
    'Generating personalized recommendations...': {
      'hi': 'व्यक्तिगत सलाह तैयार की जा रही है...',
      'mr': 'वैयक्तिक शिफारसी तयार केल्या जात आहेत...'
    },

    // Risk Messages
    'You can rest at home': {
      'hi': 'आप घर पर आराम कर सकते हैं',
      'mr': 'तुम्ही घरी विश्रांती घेऊ शकता'
    },
    'Be cautious and monitor': {
      'hi': 'सावधानी बरतें और निगरानी रखें',
      'mr': 'सावध रहा आणि लक्ष ठेवा'
    },
    'Consult doctor immediately': {
      'hi': 'तुरंत डॉक्टर से मिलें',
      'mr': 'त्वरित डॉक्टरांचा सल्ला घ्या'
    },

    // Summaries
    'Health Assessment Result: Low Risk - Home care recommended. Rest well, stay hydrated, and monitor symptoms.': {
      'hi': 'स्वास्थ्य मूल्यांकन परिणाम: कम जोखिम - घरेलू देखभाल की सिफारिश की जाती है। अच्छी तरह से आराम करें, हाइड्रेटेड रहें और लक्षणों की निगरानी करें।',
      'mr': 'आरोग्य मूल्यांकन परिणाम: कमी धोका - घरगुती काळजीची शिफारस केली जाते. विश्रांती घ्या, हायड्रेटेड रहा आणि लक्षणांवर लक्ष ठेवा.'
    },
    'Health Assessment Result: Medium Risk - Caution advised. Monitor symptoms closely and consult doctor if condition worsens.': {
      'hi': 'स्वास्थ्य मूल्यांकन परिणाम: मध्यम जोखिम - सावधानी की सलाह दी जाती है। लक्षणों की बारीकी से निगरानी करें और यदि स्थिति बिगड़ती है तो डॉक्टर से परामर्श करें।',
      'mr': 'आरोग्य मूल्यांकन परिणाम: मध्यम धोका - खबरदारीचा सल्ला दिला जातो. लक्षणांवर बारीक लक्ष ठेवा आणि स्थिती बिघडल्यास डॉक्टरांचा सल्ला घ्या.'
    },
    'Health Assessment Result: High Risk - Immediate medical attention required. Visit nearest healthcare facility without delay.': {
      'hi': 'स्वास्थ्य मूल्यांकन परिणाम: उच्च जोखिम - तत्काल चिकित्सा ध्यान देने की आवश्यकता है। बिना किसी देरी के निकटतम स्वास्थ्य सुविधा पर जाएँ।',
      'mr': 'आरोग्य मूल्यांकन परिणाम: उच्च धोका - त्वरित वैद्यकीय लक्ष आवश्यक आहे. विलंब न करता जवळच्या आरोग्य केंद्राला भेट द्या.'
    },

    // Recommendations - Low Risk
    'Take adequate rest and stay hydrated': {
      'hi': 'पर्याप्त आराम करें और पानी पीते रहें',
      'mr': 'पुरेशी विश्रांती घ्या आणि हायड्रेटेड रहा'
    },
    'Monitor your symptoms for any changes': {
      'hi': 'किसी भी बदलाव के लिए अपने लक्षणों की निगरानी करें',
      'mr': 'कोणत्याही बदलांसाठी तुमच्या लक्षणांवर लक्ष ठेवा'
    },
    'Maintain a balanced diet with nutritious food': {
      'hi': 'पौष्टिक भोजन के साथ संतुलित आहार बनाए रखें',
      'mr': 'पोषक अन्नासह संतुलित आहार ठेवा'
    },
    'Practice good hygiene and wash hands regularly': {
      'hi': 'अच्छी स्वच्छता अपनाएं और नियमित रूप से हाथ धोएं',
      'mr': 'चांगली स्वच्छता पाळा आणि नियमितपणे हात धुवा'
    },
    'Get sufficient sleep of 7-8 hours daily': {
      'hi': 'रोजाना 7-8 घंटे की पर्याप्त नींद लें',
      'mr': 'दररोज 7-8 तासांची पुरेशी झोप घ्या'
    },

    // Recommendations - Medium Risk
    'Monitor your symptoms closely for 24-48 hours': {
      'hi': '24-48 घंटों तक अपने लक्षणों की बारीकी से निगरानी करें',
      'mr': '24-48 तास तुमच्या लक्षणांवर बारीक लक्ष ठेवा'
    },
    'Keep track of temperature and other vital signs': {
      'hi': 'तापमान और अन्य महत्वपूर्ण संकेतों पर नज़र रखें',
      'mr': 'तापमान आणि इतर महत्वपूर्ण लक्षणांचा मागोवा ठेवा'
    },
    'Avoid strenuous physical activities': {
      'hi': 'ज़ोरदार शारीरिक गतिविधियों से बचें',
      'mr': 'कष्टाची शारीरिक कामे टाळा'
    },
    'Stay in touch with family members about your condition': {
      'hi': 'अपनी स्थिति के बारे में परिवार के सदस्यों के संपर्क में रहें',
      'mr': 'तुमच्या स्थितीबद्दल कुटुंबातील सदस्यांच्या संपर्कात रहा'
    },
    'Consult a doctor if symptoms worsen or persist': {
      'hi': 'लक्षण बिगड़ने या बने रहने पर डॉक्टर से परामर्श करें',
      'mr': 'लक्षणे बिघडल्यास किंवा कायम राहिल्यास डॉक्टरांचा सल्ला घ्या'
    },
    'Maintain isolation if you have fever or cough': {
      'hi': 'यदि आपको बुखार या खाँसी है तो अलगाव बनाए रखें',
      'mr': 'जर तुम्हाला ताप किंवा खोकला असेल तर अलगीकरण ठेवा'
    },

    // Recommendations - High Risk
    'Visit the nearest healthcare facility immediately': {
      'hi': 'तुरंत निकटतम स्वास्थ्य सुविधा पर जाएँ',
      'mr': 'त्वरित जवळच्या आरोग्य केंद्राला भेट द्या'
    },
    'Do not delay seeking medical attention': {
      'hi': 'चिकित्सा सहायता लेने में देरी न करें',
      'mr': 'वैद्यकीय मदत घेण्यास विलंब करू नका'
    },
    'Inform family members about your condition': {
      'hi': 'परिवार के सदस्यों को अपनी स्थिति के बारे में सूचित करें',
      'mr': 'कुटुंबातील सदस्यांना तुमच्या स्थितीबद्दल माहिती द्या'
    },
    'Carry any existing medical records with you': {
      'hi': 'अपने साथ कोई मौजूदा मेडिकल रिकॉर्ड रखें',
      'mr': 'तुमच्यासोबत जुने वैद्यकीय रेकॉर्ड ठेवा'
    },
    'Avoid self-medication without doctor consultation': {
      'hi': 'डॉक्टर के परामर्श के बिना स्व-चिकित्सा से बचें',
      'mr': 'डॉक्टरांच्या सल्ल्याशिवाय स्वतःहून औषध घेणे टाळा'
    },
    'Call emergency services if symptoms are severe': {
      'hi': 'यदि लक्षण गंभीर हैं तो आपातकालीन सेवाओं को कॉल करें',
      'mr': 'लक्षणे गंभीर असल्यास आपत्कालीन सेवांना कॉल करा'
    },
    'Keep emergency contact numbers handy': {
      'hi': 'आपातकालीन संपर्क नंबर पास रखें',
      'mr': 'आपत्कालीन संपर्क क्रमांक जवळ ठेवा'
    },

    // Nearby Hospitals Screen
    'Nearby Government Hospitals': {
      'hi': 'निकटतम सरकारी अस्पताल',
      'mr': 'जवळचे सरकारी रुग्णालय'
    },
    'Finding hospitals near you...': {
      'hi': 'आपके पास के अस्पताल खोजे जा रहे हैं...',
      'mr': 'तुमच्या जवळची रुग्णालये शोधली जात आहेत...'
    },
    'No government hospitals found within 10km.': {
      'hi': '10 किमी के भीतर कोई सरकारी अस्पताल नहीं मिला।',
      'mr': '10 किमीच्या आत कोणतेही सरकारी रुग्णालय सापडले नाही.'
    },
    'Location permission is required to find nearby hospitals.': {
      'hi': 'निकटतम अस्पताल खोजने के लिए स्थान की अनुमति आवश्यक है।',
      'mr': 'जवळची रुग्णालये शोधण्यासाठी स्थान परवानगी आवश्यक आहे.'
    },
    'Location services are disabled. Please enable them.': {
      'hi': 'स्थान सेवाएं अक्षम हैं। कृपया उन्हें सक्षम करें।',
      'mr': 'स्थान सेवा बंद आहेत. कृपया त्यांना चालू करा.'
    },
    'Failed to load hospital data. Please try again.': {
      'hi': 'अस्पताल डेटा लोड करने में विफल। कृपया पुन: प्रयास करें।',
      'mr': 'रुग्णालय डेटा लोड करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.'
    },
    'Try Again': {
      'hi': 'पुन: प्रयास करें',
      'mr': 'पुन्हा प्रयत्न करा'
    },
    'Found': {
      'hi': 'मिले',
      'mr': 'सापडले'
    },
    'hospitals within 10km': {
      'hi': 'अस्पताल (10 किमी के भीतर)',
      'mr': 'रुग्णालये (10 किमीच्या आत)'
    },
    'Unknown Address': {
      'hi': 'अज्ञात पता',
      'mr': 'अज्ञात पत्ता'
    },
    'km away': {
      'hi': 'किमी दूर',
      'mr': 'किमी दूर'
    },
    'Get Directions': {
      'hi': 'दिशानिर्देश प्राप्त करें',
      'mr': 'दिशानिर्देश मिळवा'
    },
    // Hospital Card generic Labels
    'Type': {'hi': 'प्रकार', 'mr': 'प्रकार'},
  };

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('selected_language');
      if (savedLang != null) {
        currentLanguage.value = savedLang;
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Localization init error: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (currentLanguage.value == languageCode) return;
    
    currentLanguage.value = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
  }

  /// Translates text. Returns original if English or error.
  /// Uses caching to minimize API calls.
  Future<String> translate(String text, {String? context}) async {
    final targetLang = currentLanguage.value;

    // 1. English check
    if (targetLang == 'en' || targetLang == 'English') return text;

    // 2. Check Static Cache
    if (_staticCache.containsKey(text) && _staticCache[text]!.containsKey(targetLang)) {
      return _staticCache[text]![targetLang]!;
    }

    // 3. Check Dynamic Cache
    if (_translationCache.containsKey(text) && _translationCache[text]!.containsKey(targetLang)) {
      return _translationCache[text]![targetLang]!;
    }

    // 4. Call Gemini
    try {
      final translated = await GeminiService().translateText(
        text: text,
        targetLanguage: targetLang,
        context: context,
      );

      // 5. Update Cache
      if (!_translationCache.containsKey(text)) {
        _translationCache[text] = {};
      }
      _translationCache[text]![targetLang] = translated;

      return translated;
    } catch (e) {
      return text;
    }
  }

  /// Synchronous translation for static cache items.
  /// Falls back to original text if not found in static cache.
  String translateSync(String text) {
    final targetLang = currentLanguage.value;
    if (targetLang == 'en' || targetLang == 'English') return text;

    if (_staticCache.containsKey(text) && _staticCache[text]!.containsKey(targetLang)) {
      return _staticCache[text]![targetLang]!;
    }
    if (_translationCache.containsKey(text) && _translationCache[text]!.containsKey(targetLang)) {
      return _translationCache[text]![targetLang]!;
    }

    return text;
  }
  
  // Helper to get current language code
  String get langCode => currentLanguage.value;
}
