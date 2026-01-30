import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
            Text('Emergency Helpline'),
          ],
        ),
        content: const Text(
          'This will call the ambulance helpline (108). Do you want to proceed?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
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
                Text('Call 108'),
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
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showToast(context, 'Could not launch dialer.');
      }
    } catch (e) {
      _showToast(context, 'Error launching dialer: $e');
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
