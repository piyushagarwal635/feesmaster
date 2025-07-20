import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StudentInfoCard extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const StudentInfoCard({
    Key? key,
    required this.studentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceVariant(isLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getOutlineColor(isLight),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Student Photo
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.getOutlineColor(isLight),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: CustomImageWidget(
                imageUrl: (studentData["photo"] as String?) ??
                    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 4.w),

          // Student Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (studentData["name"] as String?) ?? "Unknown Student",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 0.5.h),

                Text(
                  "ID: ${(studentData["studentId"] as String?) ?? "N/A"}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isLight
                            ? AppTheme.onSurfaceVariantLight
                            : AppTheme.onSurfaceVariantDark,
                      ),
                ),

                SizedBox(height: 1.h),

                // Outstanding Amount
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.getErrorColor(isLight).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.getErrorColor(isLight)
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'account_balance_wallet',
                        color: AppTheme.getErrorColor(isLight),
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "Outstanding: \$${((studentData["outstandingAmount"] as num?) ?? 0.0).toStringAsFixed(2)}",
                        style: AppTheme.dataTextStyle(
                          isLight: isLight,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ).copyWith(
                          color: AppTheme.getErrorColor(isLight),
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
