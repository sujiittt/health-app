import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../services/localization_service.dart';

/// A robust widget to display AI-generated health guidance.
/// Handles structured data (Summary, Advice, Warnings) and unstructured fallback.
class AiResponseViewer extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool showRiskCard; // Option to include specific risk UI if passed separately, but usually better handled by parent.
  // Actually, this widget should focus on the Text Content: Summary, Recommendations, Warnings, Cultural Tips.

  const AiResponseViewer({
    super.key, 
    required this.data, 
    this.showRiskCard = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildFallback(context);
    }

    // Extract fields with flexible keys
    final summary = _getString(data, ['summary', 'overview', 'description']);
    final advice = _getListOrString(data, ['recommendations', 'advice', 'steps']);
    final warnings = _getListOrString(data, ['warningSigns', 'warnings', 'redFlags']);
    final culturalTips = _getListOrString(data, ['culturalTips', 'homeRemedies', 'tips']);

    // Check if we have structured content
    final hasStructuredContent = advice.isNotEmpty || warnings.isNotEmpty || culturalTips.isNotEmpty;

    // If we only have a summary and it's long, treating it as "Guidance"
    final isUnstructured = !hasStructuredContent && summary.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isUnstructured)
          _buildSection(
            context,
            title: 'Health Guidance',
            content: summary,
            icon: Icons.health_and_safety,
            color: Theme.of(context).colorScheme.primary,
          )
        else ...[
          // Summary
          if (summary.isNotEmpty)
            _buildSection(
              context,
              title: 'Summary',
              content: summary,
              icon: Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          
          // Advice / Recommendations
          if (advice.isNotEmpty)
            _buildSection(
              context,
              title: 'Recommendations',
              content: advice,
              icon: Icons.medical_services_outlined,
              color: Colors.blue.shade700,
            ),

          // Cultural / Home Remedies
          if (culturalTips.isNotEmpty)
            _buildSection(
              context,
              title: 'Home Remedies',
              content: culturalTips,
              icon: Icons.spa, // Leaf/Spa icon
              color: Colors.green.shade700,
            ),

          // Warning Signs
          if (warnings.isNotEmpty)
            _buildSection(
              context,
              title: 'When to Seek Help',
              content: warnings,
              icon: Icons.warning_amber_rounded,
              color: Colors.orange.shade900,
              bgColor: Colors.orange.shade50,
              borderColor: Colors.orange.shade200,
            ),
        ],
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    Color? color,
    Color? bgColor,
    Color? borderColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: bgColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
              SizedBox(width: 2.w),
              Text(
                LocalizationService().translateSync(title), // Translate Title
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 11.sp,
              height: 1.5,
              color: color != null && bgColor != null ? color : theme.colorScheme.onSurface.withOpacity(0.8), 
              // If it's a warning card (colored bg), use the dark color for text too for contrast
              // Otherwise use standard text color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Text(
          LocalizationService().translateSync('No guidance available.'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  // --- Helpers ---

  String _getString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data[key] != null && data[key].toString().trim().isNotEmpty) {
        String val = data[key].toString().trim();
        // Check if value is actually a JSON string (double-failsafe)
        if (val.startsWith('{') && val.contains('}')) {
           // Skip if it looks like JSON, we don't want to show raw JSON as a string
           // But actually, we should try to extract the real 'summary' from inside it if possible!
           // This is complex for a purely presentational widget, so we'll just clean it.
           // Better strategy: If we find a key "summary": inside, try to substring it.
           // Regex to extract value of "summary": "..."
           final match = RegExp(r'"summary"\s*:\s*"([^"]*)"').firstMatch(val);
           if (match != null) return match.group(1) ?? val;
        }
        return val;
      }
    }
    return '';
  }

  String _getListOrString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final val = data[key];
      if (val == null) continue;
      
      if (val is List) {
        if (val.isEmpty) continue;
        return val.map((e) => '• ${e.toString().trim()}').join('\n\n');
      } else if (val is String) {
        if (val.trim().isEmpty) continue;
        
        // Improvement: If string has newlines, format as bullets
        if (val.contains('\n')) {
           final lines = val.split('\n');
           final buffer = StringBuffer();
           for (var line in lines) {
             final trimmed = line.trim();
             if (trimmed.isEmpty) continue;
             if (trimmed.startsWith('-') || trimmed.startsWith('•') || RegExp(r'^\d+\.').hasMatch(trimmed)) {
                buffer.write('$trimmed\n\n');
             } else {
                buffer.write('• $trimmed\n\n');
             }
           }
           return buffer.toString().trim();
        }
        return val.trim();
      }
    }
    return '';
  }
}
