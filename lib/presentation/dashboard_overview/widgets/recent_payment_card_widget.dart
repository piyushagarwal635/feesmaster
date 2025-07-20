import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentPaymentCardWidget extends StatelessWidget {
  final Map<String, dynamic> payment;

  const RecentPaymentCardWidget({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = payment["status"] as String;
    final statusColor = _getStatusColor(status, isDark);

    return Container(
      width: 80.w,
      margin: EdgeInsets.only(right: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceVariant(isDark == false),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getOutlineColor(isDark == false),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: _getStatusIcon(status),
                    color: statusColor,
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment["studentName"] as String,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      payment["course"] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment["amount"] as String,
                    style: AppTheme.dataTextStyleEmphasis(
                      isLight: isDark == false,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: statusColor),
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 9.sp,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                payment["date"] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Spacer(),
              CustomIconWidget(
                iconName: 'receipt',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                payment["receiptId"] as String,
                style: AppTheme.dataTextStyle(
                  isLight: isDark == false,
                  fontSize: 10.sp,
                ).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.getSuccessColor(isDark == false);
      case 'pending':
        return AppTheme.getWarningColor(isDark == false);
      case 'overdue':
        return AppTheme.getErrorColor(isDark == false);
      default:
        return AppTheme.getWarningColor(isDark == false);
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'check_circle';
      case 'pending':
        return 'schedule';
      case 'overdue':
        return 'error';
      default:
        return 'schedule';
    }
  }
}
