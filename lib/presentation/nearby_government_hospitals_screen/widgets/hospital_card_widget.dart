import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../nearby_government_hospitals_screen.dart';

/// Widget to display individual hospital information card
class HospitalCardWidget extends StatelessWidget {
  final Hospital hospital;

  const HospitalCardWidget({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_hospital,
              color: const Color(0xFFD32F2F),
              size: 7.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 4.w,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        hospital.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation,
                        size: 4.w,
                        color: const Color(0xFF2E7D32),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${hospital.distance?.toStringAsFixed(1)} km away',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
