import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget to display color-coded risk assessment card
/// Supports three risk levels: Low (Green), Medium (Yellow), High (Red)
class RiskLevelCardWidget extends StatelessWidget {
  final String riskLevel;
  final String riskMessage;
  final Color cardColor;
  final String iconName;

  const RiskLevelCardWidget({
    super.key,
    required this.riskLevel,
    required this.riskMessage,
    required this.cardColor,
    required this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 90.w,
      constraints: BoxConstraints(minHeight: 25.h, maxHeight: 35.h),
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: Colors.white,
                size: 10.w,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            riskLevel,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: cardColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            riskMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
