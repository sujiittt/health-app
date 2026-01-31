import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/translated_text.dart';

class EmergencyHelper {
  /// Shows a confirmation dialog and dials the emergency number (108) if confirmed.
  static Future<void> showEmergencyDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            TrText('Emergency Helpline'),
          ],
        ),
        content: const TrText(
          'This will call the ambulance helpline (108). Do you want to proceed?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: TrText(
              'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launchEmergencyNumber(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.call, size: 18),
                SizedBox(width: 8),
                TrText('Call 108'), // Keep 108 static or TrText? 108 is number. 'Call 108' -> '108 कॉल करें'. TrText fits.
              ],
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Future<void> _launchEmergencyNumber(BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: '108');
    try {
      // Try launching directly with external application mode
      // This is often more reliable for dialers than checking canLaunchUrl first on some Android versions
      bool launched = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
         // Fallback: Try platform default
         launched = await launchUrl(launchUri);
      }

      if (!launched) {
        if (context.mounted) _showToast(context, 'Could not launch dialer.');
      }
    } catch (e) {
      if (context.mounted) _showToast(context, 'Error launching dialer: $e');
    }
  }

  static void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
