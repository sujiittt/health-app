import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual symptom card widget with icon, label, and selection state
/// Implements large touch targets and visual feedback for rural users
class SymptomCardWidget extends StatelessWidget {
  final String symptomName;
  final String iconName;
  final bool isSelected;
  final VoidCallback onTap;

  const SymptomCardWidget({
    super.key,
    required this.symptomName,
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.primary.withValues(alpha: 0.1))
              : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
          child: FittedBox(
             fit: BoxFit.scaleDown,
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Stack(
                   alignment: Alignment.topRight,
                   children: [
                     CustomIconWidget(
                       iconName: iconName,
                       size: 56,
                       color: isSelected
                           ? theme.colorScheme.primary
                           : (isDark
                           ? const Color(0xFFB0B0B0)
                           : const Color(0xFF757575)),
                     ),
                     if (isSelected)
                       Container(
                         padding: const EdgeInsets.all(2),
                         decoration: BoxDecoration(
                           color: theme.colorScheme.primary,
                           shape: BoxShape.circle,
                         ),
                         child: CustomIconWidget(
                           iconName: 'check',
                           size: 16,
                           color: isDark
                               ? const Color(0xFF000000)
                               : const Color(0xFFFFFFFF),
                         ),
                       ),
                   ],
                 ),
                 SizedBox(height: 1.h),
                 Text(
                   symptomName,
                   textAlign: TextAlign.center,
                   style: theme.textTheme.titleMedium?.copyWith(
                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                     color: isSelected
                         ? theme.colorScheme.primary
                         : (isDark
                         ? const Color(0xFFFFFFFF)
                         : const Color(0xFF212121)),
                   ),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
               ],
             ),
          ),
        ),
      ),
    );
  }
}
