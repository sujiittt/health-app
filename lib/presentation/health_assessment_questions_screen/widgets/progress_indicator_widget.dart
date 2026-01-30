import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Widget to display progress through questions
class ProgressIndicatorWidget extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final String progressText;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = currentQuestion / totalQuestions;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFB0B0B0)
                      : const Color(0xFF757575),
                ),
              ),
              Text(
                '$currentQuestion/$totalQuestions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF212121),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? const Color(0xFF424242)
                  : const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
