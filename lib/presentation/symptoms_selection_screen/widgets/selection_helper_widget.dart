import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Helper text widget shown when no symptoms are selected
/// Provides guidance to users on how to proceed
class SelectionHelperWidget extends StatelessWidget {
  final String helperText;

  const SelectionHelperWidget({super.key, required this.helperText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0x1FFFFFFF)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'info_outline',
            size: 24,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              helperText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? const Color(0xFFB0B0B0)
                    : const Color(0xFF757575),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
