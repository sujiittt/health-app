
class AppConfig {
  // Centralized Base URL Configuration
  // "localhost" works for:
  // 1. iOS Simulator (natively)
  // 2. Android Emulator (IF 'adb reverse tcp:3000 tcp:3000' is run)
  // 3. Physical Android Device (IF 'adb reverse tcp:3000 tcp:3000' is run via USB)
  //
  // NOTE: '10.0.2.2' is no longer used to ensure consistency across devices.
  static const String _domain = 'localhost'; 
  static const String _port = '3000';
  
  static const String apiBaseUrl = 'http://$_domain:$_port/api/assessment';

  // Timeout for API calls
  static const Duration apiTimeout = Duration(seconds: 20);
}
