import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
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
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context,
                'Record Payment',
                'payment',
                Theme.of(context).colorScheme.primary,
                () => Navigator.pushNamed(context, '/record-payment'),
              ),
              _buildActionButton(
                context,
                'Add Student',
                'person_add',
                AppTheme.getSuccessColor(isDark == false),
                () => Navigator.pushNamed(context, '/add-new-student'),
              ),
              _buildActionButton(
                context,
                'Send Reminders',
                'notifications',
                AppTheme.getWarningColor(isDark == false),
                () => _showReminderDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25.w,
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Reminders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.getWarningColor(
                    Theme.of(context).brightness == Brightness.light),
                size: 6.w,
              ),
              title: Text('Due Today (12 students)'),
              onTap: () {
                Navigator.pop(context);
                _sendReminders('due_today');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'error',
                color: AppTheme.getErrorColor(
                    Theme.of(context).brightness == Brightness.light),
                size: 6.w,
              ),
              title: Text('Overdue (8 students)'),
              onTap: () {
                Navigator.pop(context);
                _sendReminders('overdue');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('All Pending (25 students)'),
              onTap: () {
                Navigator.pop(context);
                _sendReminders('all_pending');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _sendReminders(String type) {
    // Implementation for sending reminders
    print('Sending reminders for: $type');
  }
}
