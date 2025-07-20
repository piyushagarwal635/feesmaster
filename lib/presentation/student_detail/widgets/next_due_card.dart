import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NextDueCard extends StatefulWidget {
  final Map<String, dynamic> dueInfo;

  const NextDueCard({
    Key? key,
    required this.dueInfo,
  }) : super(key: key);

  @override
  State<NextDueCard> createState() => _NextDueCardState();
}

class _NextDueCardState extends State<NextDueCard> {
  late DateTime dueDate;
  late Duration timeRemaining;

  @override
  void initState() {
    super.initState();
    dueDate = DateTime.parse(widget.dueInfo['dueDate'] as String? ??
        DateTime.now().add(Duration(days: 30)).toIso8601String());
    _updateTimeRemaining();
  }

  void _updateTimeRemaining() {
    setState(() {
      timeRemaining = dueDate.difference(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = timeRemaining.isNegative;
    final bool isDueSoon = timeRemaining.inDays <= 3 && !isOverdue;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: isOverdue
          ? AppTheme.getErrorColor(
                  Theme.of(context).brightness == Brightness.light)
              .withValues(alpha: 0.1)
          : isDueSoon
              ? AppTheme.getWarningColor(
                      Theme.of(context).brightness == Brightness.light)
                  .withValues(alpha: 0.1)
              : null,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: isOverdue ? 'warning' : 'schedule',
                  color: isOverdue
                      ? AppTheme.getErrorColor(
                          Theme.of(context).brightness == Brightness.light)
                      : isDueSoon
                          ? AppTheme.getWarningColor(
                              Theme.of(context).brightness == Brightness.light)
                          : Theme.of(context).colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  isOverdue ? 'Overdue Payment' : 'Next Due Date',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isOverdue
                            ? AppTheme.getErrorColor(
                                Theme.of(context).brightness ==
                                    Brightness.light)
                            : null,
                      ),
                ),
                Spacer(),
                if (isOverdue || isDueSoon)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? AppTheme.getErrorColor(
                              Theme.of(context).brightness == Brightness.light)
                          : AppTheme.getWarningColor(
                              Theme.of(context).brightness == Brightness.light),
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: Text(
                      isOverdue ? 'OVERDUE' : 'DUE SOON',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _formatDate(dueDate),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount Due',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        widget.dueInfo['amount'] as String? ?? '\$0.00',
                        style: AppTheme.dataTextStyleEmphasis(
                          isLight:
                              Theme.of(context).brightness == Brightness.light,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ).copyWith(
                          color: isOverdue
                              ? AppTheme.getErrorColor(
                                  Theme.of(context).brightness ==
                                      Brightness.light)
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Column(
                children: [
                  Text(
                    isOverdue ? 'Overdue by' : 'Time Remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTimeUnit(
                        context,
                        isOverdue
                            ? timeRemaining.inDays.abs().toString()
                            : timeRemaining.inDays.toString(),
                        'Days',
                        isOverdue,
                      ),
                      _buildTimeUnit(
                        context,
                        isOverdue
                            ? (timeRemaining.inHours.abs() % 24).toString()
                            : (timeRemaining.inHours % 24).toString(),
                        'Hours',
                        isOverdue,
                      ),
                      _buildTimeUnit(
                        context,
                        isOverdue
                            ? (timeRemaining.inMinutes.abs() % 60).toString()
                            : (timeRemaining.inMinutes % 60).toString(),
                        'Minutes',
                        isOverdue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isOverdue || isDueSoon) ...[
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/record-payment');
                  },
                  icon: CustomIconWidget(
                    iconName: 'payment',
                    color: Colors.white,
                    size: 5.w,
                  ),
                  label: Text('Record Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverdue
                        ? AppTheme.getErrorColor(
                            Theme.of(context).brightness == Brightness.light)
                        : AppTheme.getWarningColor(
                            Theme.of(context).brightness == Brightness.light),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(
      BuildContext context, String value, String unit, bool isOverdue) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isOverdue
                ? AppTheme.getErrorColor(
                        Theme.of(context).brightness == Brightness.light)
                    .withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(1.w),
          ),
          child: Text(
            value,
            style: AppTheme.dataTextStyleEmphasis(
              isLight: Theme.of(context).brightness == Brightness.light,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ).copyWith(
              color: isOverdue
                  ? AppTheme.getErrorColor(
                      Theme.of(context).brightness == Brightness.light)
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
