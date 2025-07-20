import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MultiSelectActionsWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onClearSelection;
  final VoidCallback onSendReminders;
  final VoidCallback onUpdateFeeStructure;
  final VoidCallback onBulkDelete;

  const MultiSelectActionsWidget({
    Key? key,
    required this.selectedCount,
    required this.onClearSelection,
    required this.onSendReminders,
    required this.onUpdateFeeStructure,
    required this.onBulkDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Close button
            IconButton(
              onPressed: onClearSelection,
              icon: CustomIconWidget(
                iconName: 'close',
                color: Colors.white,
                size: 6.w,
              ),
            ),

            SizedBox(width: 2.w),

            // Selected count
            Expanded(
              child: Text(
                '$selectedCount student${selectedCount == 1 ? '' : 's'} selected',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Action buttons
            Row(
              children: [
                // Send reminders
                IconButton(
                  onPressed: onSendReminders,
                  icon: CustomIconWidget(
                    iconName: 'notifications',
                    color: Colors.white,
                    size: 6.w,
                  ),
                  tooltip: 'Send Reminders',
                ),

                // Update fee structure
                IconButton(
                  onPressed: onUpdateFeeStructure,
                  icon: CustomIconWidget(
                    iconName: 'edit',
                    color: Colors.white,
                    size: 6.w,
                  ),
                  tooltip: 'Update Fee Structure',
                ),

                // Bulk delete
                IconButton(
                  onPressed: () async {
                    final bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Students'),
                        content: Text(
                          'Are you sure you want to delete $selectedCount student${selectedCount == 1 ? '' : 's'}? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.getErrorColor(isLight),
                            ),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      onBulkDelete();
                    }
                  },
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: Colors.white,
                    size: 6.w,
                  ),
                  tooltip: 'Delete Selected',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
