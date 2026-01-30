import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Widget for navigation buttons (Previous/Next/Get Results)
class NavigationButtonsWidget extends StatelessWidget {
  final bool showPrevious;
  final bool showNext;
  final bool showGetResults;
  final VoidCallback? onPreviousTap;
  final VoidCallback? onNextTap;
  final VoidCallback? onGetResultsTap;
  final String previousText;
  final String nextText;
  final String getResultsText;
  final bool isNextEnabled;

  const NavigationButtonsWidget({
    super.key,
    required this.showPrevious,
    required this.showNext,
    required this.showGetResults,
    this.onPreviousTap,
    this.onNextTap,
    this.onGetResultsTap,
    required this.previousText,
    required this.nextText,
    required this.getResultsText,
    this.isNextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showPrevious)
            Expanded(
              child: OutlinedButton(
                onPressed: onPreviousTap,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 6.h),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFF4CAF50),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  previousText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ),
          if (showPrevious && (showNext || showGetResults))
            SizedBox(width: 3.w),
          if (showNext)
            Expanded(
              child: ElevatedButton(
                onPressed: isNextEnabled ? onNextTap : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 6.h),
                  backgroundColor: isNextEnabled
                      ? (isDark
                      ? const Color(0xFF66BB6A)
                      : const Color(0xFF4CAF50))
                      : (isDark
                      ? const Color(0xFF424242)
                      : const Color(0xFFE0E0E0)),
                  foregroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  nextText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          if (showGetResults)
            Expanded(
              child: ElevatedButton(
                onPressed: onGetResultsTap,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 6.h),
                  backgroundColor: isDark
                      ? const Color(0xFF66BB6A)
                      : const Color(0xFF4CAF50),
                  foregroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  getResultsText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
