import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();

  // ===========================================================================
  // CONFIGURATION START
  // ===========================================================================
  
  // 1. EMULATOR: Use 'http://10.0.2.2:3000/api/assessment'
  // 2. REAL DEVICE: Use your computer's local IP, e.g., 'http://192.168.1.5:3000/api/assessment'
  
  // Set your computer's IP here for real device testing:
  static const String _physicalDeviceIp = '192.168.1.100'; // CHANGE THIS TO YOUR PC IP
  
  static String get _baseUrl {
    if (kReleaseMode) {
      // Production URL (if deployed)
      return 'https://your-production-server.com/api/assessment';
    }
    
    // Auto-detection logic (basic):
    // Android Emulator usually can access 10.0.2.2.
    // Physical devices need the LAN IP.
    // Since we can't easily detect "Physical" vs "Emulator" purely in Dart io without plugins,
    // we use a simple toggle or just use the LAN IP if expecting real device.
    
    // For now, defaulting to Emulator for simplicity unless manually changed here.
    // To switch to Real Device, easier to just uncomment the IP version below.
    
    return 'http://10.0.2.2:3000/api/assessment';
    // return 'http://$_physicalDeviceIp:3000/api/assessment'; // Uncomment for Real Device
  }

  static const Duration _timeoutDuration = Duration(seconds: 20); // 20s timeout

  // ===========================================================================
  // CONFIGURATION END
  // ===========================================================================

  factory GeminiService() => _instance;

  GeminiService._internal();

  Future<Map<String, dynamic>> generateHealthRecommendations({
    required List<String> symptoms,
    required String riskLevel,
    required String age,
    required String gender,
    required String language,
    String? description,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/generate');
      
      if (kDebugMode) {
        print('GeminiService: Sending request to $uri');
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'symptoms': symptoms,
          'age': age,
          'gender': gender,
          'description': description ?? '',
          'language': language,
        }),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        // Offload JSON parsing AND smart formatting to Isolate
        final jsonResponse = await compute(_parseAndFormatJson, response.body);
        
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        } else {
           throw GeminiException(jsonResponse['message'] ?? 'Unknown Backend Error');
        }
      } else {
        throw GeminiException('Server Error: ${response.statusCode}');
      }
    } on SocketException {
      throw GeminiException('Connection invalid. Check your internet or server IP.');
    } on TimeoutException {
      throw GeminiException('Request timed out. Server is taking too long.');
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw GeminiException('Failed to connect: $e');
    }
  }

  // Top-level function for isolate: Parses JSON and Smart-Formats text
  static Map<String, dynamic> _parseAndFormatJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded['success'] != true || decoded['data'] == null) return decoded;

      final data = Map<String, dynamic>.from(decoded['data']);
      
      // --- Helper internal functions for formatter ---
      List<String> splitSmartly(String text) {
        if (text.trim().isEmpty) return [];
        // Split by numbered lists (1., 2.) or bullets
        if (text.contains(RegExp(r'^\s*\d+\.', multiLine: true)) || text.contains('\n-') || text.contains('\n•')) {
           return text.split(RegExp(r'\n(?=\d+\.|- |• )'))
                      .map((e) => e.replaceAll(RegExp(r'^\s*(\d+\.|-|•)\s*'), '').trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
        }
        // Split by newlines if simple list
        if (text.contains('\n')) {
           return text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
        // Return single sentence logic could go here but maybe safer to keep as block
        return [text];
      }

      // --- 1. Fix Fields that should be Lists ---
      // Recommendations
      if (data['recommendations'] is String) {
        data['recommendations'] = splitSmartly(data['recommendations']);
      }
      // Warnings
      if (data['warningSigns'] is String) {
         data['warningSigns'] = splitSmartly(data['warningSigns']);
      }
      // Cultural Tips
      if (data['culturalTips'] is String) {
         data['culturalTips'] = splitSmartly(data['culturalTips']);
      }

      // --- 2. Smart Fallback if Summary contains everything ---
      // Sometimes AI puts everything in 'summary' or 'rawText'
      String summary = data['summary']?.toString() ?? '';
      if (summary.isEmpty) summary = data['rawText']?.toString() ?? '';
      
      if ((data['recommendations'] == null || (data['recommendations'] as List).isEmpty) && summary.length > 200) {
          // Attempt to extract recommendations from summary
          // Look for keywords like "Recommendations:", "Advice:", "Steps:"
          final recMatch = RegExp(r'(?:Recommendations|Advice|Steps|Suggestions|Upay)[:\s\n]+((?:.|\n)*?)(?:Warning|Risk|Note|$)', caseSensitive: false).firstMatch(summary);
          if (recMatch != null) {
              final recText = recMatch.group(1);
              if (recText != null) {
                 data['recommendations'] = splitSmartly(recText);
                 // Optional: Remove it from summary to avoid duplication? 
                 // Maybe risky, let's leave it unless summary is huge.
              }
          }
      }

      decoded['data'] = data;
      return decoded;
    } catch (e) {
      // Fallback if formatting fails: return original parse or error
      try {
        return jsonDecode(jsonString);
      } catch (_) {
         return {'success': false, 'message': 'Invalid JSON response'};
      }
    }
  }

  /// Generates general guidance for "Tell Us More" screen
  Future<Map<String, dynamic>> generateGeneralGuidance({
    required String gender,
    required String age,
    required String description,
    required List<String> selectedChips,
    String language = 'English',
  }) async {
    return generateHealthRecommendations(
        symptoms: selectedChips,
        riskLevel: "Unknown", 
        age: age,
        gender: gender,
        language: language,
        description: description
    );
  }

  /// Translates a single text string
  /// Client-side mock for now to keep UI snappy. 
  Future<String> translateText({
    required String text,
    required String targetLanguage,
    String? context,
  }) async {
    if (text.trim().isEmpty) return text;
    if (targetLanguage.toLowerCase() == 'english' || targetLanguage.toLowerCase() == 'en') {
      return text;
    }
    return _getMockTranslation(text, targetLanguage);
  }
  
  String _getMockTranslation(String text, String lang) {
     if (lang == 'hi') {
       if (text == 'Next') return 'अगला';
       if (text == 'Continue') return 'जारी रखें';
       if (text.contains('select')) return 'कृपया चुनें';
       if (text.contains('Different Problem')) return 'अन्य समस्या';
       if (text == 'Assessment Results') return 'मूल्यांकन परिणाम';
       if (text == 'AI Health Insights') return 'एआई स्वास्थ्य जानकारी';
       if (text == 'Home Remedies') return 'घरेलू उपचार';
       if (text == 'When to Seek Help') return 'डॉक्टर को कब दिखाएं';
       if (text.contains('Find Nearby')) return 'निकटतम अस्पताल खोजें';
     }
     if (lang == 'mr') {
       if (text == 'Next') return 'पुढील';
       if (text == 'Continue') return 'पुढे जा';
       if (text.contains('select')) return 'कृपया निवडा';
       if (text.contains('Different Problem')) return 'इतर समस्या';
       if (text == 'Assessment Results') return 'मूल्यांकन निकाल';
       if (text == 'AI Health Insights') return 'एआय आरोग्य माहिती';
       if (text == 'Home Remedies') return 'घरगुती उपाय';
       if (text == 'When to Seek Help') return 'मदत कधी घ्यावी';
       if (text.contains('Find Nearby')) return 'जवळची रुग्णालये शोधा';
     }
     return text;
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);
  @override
  String toString() => message;
}
