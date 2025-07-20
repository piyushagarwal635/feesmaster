import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class FeeStructureCard extends StatelessWidget {
  final Map<String, dynamic> feeStructure;

  const FeeStructureCard({
    Key? key,
    required this.feeStructure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'account_balance_wallet',
                  color: Theme.of(context).colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Fee Structure',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  child: Text(
                    feeStructure['type'] as String? ?? 'Monthly',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildFeeRow(
              context,
              'Course Fee',
              feeStructure['courseFee'] as String? ?? '\$0.00',
              isMain: true,
            ),
            SizedBox(height: 1.h),
            _buildFeeRow(
              context,
              'Registration Fee',
              feeStructure['registrationFee'] as String? ?? '\$0.00',
            ),
            SizedBox(height: 1.h),
            _buildFeeRow(
              context,
              'Material Fee',
              feeStructure['materialFee'] as String? ?? '\$0.00',
            ),
            SizedBox(height: 1.h),
            _buildFeeRow(
              context,
              'Lab Fee',
              feeStructure['labFee'] as String? ?? '\$0.00',
            ),
            SizedBox(height: 2.h),
            Divider(color: Theme.of(context).dividerColor),
            SizedBox(height: 1.h),
            _buildFeeRow(
              context,
              'Total Amount',
              feeStructure['totalAmount'] as String? ?? '\$0.00',
              isTotal: true,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Mode',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        feeStructure['paymentMode'] as String? ?? 'Monthly',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
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
                        'Installments',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${feeStructure['installments'] ?? 12} months',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(
    BuildContext context,
    String label,
    String amount, {
    bool isMain = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
              : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isMain ? FontWeight.w500 : FontWeight.w400,
                  ),
        ),
        Text(
          amount,
          style: isTotal
              ? AppTheme.dataTextStyleEmphasis(
                  isLight: Theme.of(context).brightness == Brightness.light,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )
              : AppTheme.dataTextStyle(
                  isLight: Theme.of(context).brightness == Brightness.light,
                  fontSize: isMain ? 15.sp : 14.sp,
                  fontWeight: isMain ? FontWeight.w500 : FontWeight.w400,
                ),
        ),
      ],
    );
  }
}
