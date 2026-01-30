import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Widget to display individual question with yes/no options
class QuestionCardWidget extends StatelessWidget {
  final String question;
  final bool? selectedAnswer;
  final Function(bool) onAnswerSelected;
  final String yesText;
  final String noText;

  const QuestionCardWidget({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.yesText,
    required this.noText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildAnswerButton(
                  context: context,
                  label: yesText,
                  isSelected: selectedAnswer == true,
                  onTap: () => onAnswerSelected(true),
                  isYes: true,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildAnswerButton(
                  context: context,
                  label: noText,
                  isSelected: selectedAnswer == false,
                  onTap: () => onAnswerSelected(false),
                  isYes: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isYes,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      if (isYes) {
        backgroundColor = isDark
            ? const Color(0xFF66BB6A)
            : const Color(0xFF4CAF50);
        textColor = const Color(0xFFFFFFFF);
        borderColor = backgroundColor;
      } else {
        backgroundColor = isDark
            ? const Color(0xFF424242)
            : const Color(0xFFE0E0E0);
        textColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF212121);
        borderColor = backgroundColor;
      }
    } else {
      backgroundColor = isDark
          ? const Color(0xFF2D2D2D)
          : const Color(0xFFF5F5F5);
      textColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575);
      borderColor = isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
