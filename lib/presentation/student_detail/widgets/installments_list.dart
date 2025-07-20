import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class InstallmentsList extends StatelessWidget {
  final List<Map<String, dynamic>> installments;

  const InstallmentsList({
    Key? key,
    required this.installments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (installments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'event_note',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Installments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Installment schedule will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final paidInstallments =
        installments.where((i) => i['status'] == 'paid').length;
    final totalInstallments = installments.length;
    final progress = paidInstallments / totalInstallments;

    return Column(
      children: [
        // Progress Overview
        Container(
          margin: EdgeInsets.all(4.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '$paidInstallments/$totalInstallments',
                    style: AppTheme.dataTextStyleEmphasis(
                      isLight: Theme.of(context).brightness == Brightness.light,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ).copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 1.h,
              ),
              SizedBox(height: 1.h),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        // Installments List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: installments.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final installment = installments[index];
              return _buildInstallmentItem(context, installment, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentItem(BuildContext context,
      Map<String, dynamic> installment, int installmentNumber) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final String status = installment['status'] as String? ?? 'pending';
    final DateTime dueDate = DateTime.parse(
        installment['dueDate'] as String? ?? DateTime.now().toIso8601String());
    final bool isOverdue =
        status == 'pending' && dueDate.isBefore(DateTime.now());
    final bool isDueSoon =
        status == 'pending' && dueDate.difference(DateTime.now()).inDays <= 3;

    return Card(
      color: status == 'paid'
          ? AppTheme.getSuccessColor(isLight).withValues(alpha: 0.05)
          : isOverdue
              ? AppTheme.getErrorColor(isLight).withValues(alpha: 0.05)
              : isDueSoon
                  ? AppTheme.getWarningColor(isLight).withValues(alpha: 0.05)
                  : null,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status, isOverdue, isDueSoon)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getStatusColor(status, isOverdue, isDueSoon),
                      width: 0.3.w,
                    ),
                  ),
                  child: Center(
                    child: status == 'paid'
                        ? CustomIconWidget(
                            iconName: 'check',
                            color:
                                _getStatusColor(status, isOverdue, isDueSoon),
                            size: 5.w,
                          )
                        : Text(
                            installmentNumber.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: _getStatusColor(
                                      status, isOverdue, isDueSoon),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Installment $installmentNumber',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _formatDate(dueDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      installment['amount'] as String? ?? '\$0.00',
                      style: AppTheme.dataTextStyleEmphasis(
                        isLight: isLight,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ).copyWith(
                        color: _getStatusColor(status, isOverdue, isDueSoon),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status, isOverdue, isDueSoon)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                      child: Text(
                        _getStatusText(status, isOverdue, isDueSoon),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  _getStatusColor(status, isOverdue, isDueSoon),
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (status == 'paid') ...[
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.getSuccessColor(isLight).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(
                    color: AppTheme.getSuccessColor(isLight)
                        .withValues(alpha: 0.3),
                    width: 0.2.w,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.getSuccessColor(isLight),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paid on ${_formatDate(DateTime.parse(installment['paidDate'] as String? ?? DateTime.now().toIso8601String()))}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.getSuccessColor(isLight),
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          if (installment['paymentMethod'] != null)
                            Text(
                              'via ${installment['paymentMethod']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.getSuccessColor(isLight)
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showReceiptOptions(context, installment),
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: AppTheme.getSuccessColor(isLight)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: CustomIconWidget(
                          iconName: 'receipt',
                          color: AppTheme.getSuccessColor(isLight),
                          size: 4.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isOverdue || isDueSoon) ...[
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
                    size: 4.w,
                  ),
                  label: Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _getStatusColor(status, isOverdue, isDueSoon),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, bool isOverdue, bool isDueSoon) {
    if (status == 'paid') {
      return AppTheme.getSuccessColor(true);
    } else if (isOverdue) {
      return AppTheme.getErrorColor(true);
    } else if (isDueSoon) {
      return AppTheme.getWarningColor(true);
    } else {
      return Colors.grey;
    }
  }

  String _getStatusText(String status, bool isOverdue, bool isDueSoon) {
    if (status == 'paid') {
      return 'PAID';
    } else if (isOverdue) {
      return 'OVERDUE';
    } else if (isDueSoon) {
      return 'DUE SOON';
    } else {
      return 'PENDING';
    }
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

  void _showReceiptOptions(
      BuildContext context, Map<String, dynamic> installment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('View Receipt'),
              onTap: () {
                Navigator.pop(context);
                // View receipt logic
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Download Receipt'),
              onTap: () {
                Navigator.pop(context);
                // Download receipt logic
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Share Receipt'),
              onTap: () {
                Navigator.pop(context);
                // Share receipt logic
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
