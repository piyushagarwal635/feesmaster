import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChangeCalculatorDialog extends StatefulWidget {
  final double paymentAmount;

  const ChangeCalculatorDialog({
    Key? key,
    required this.paymentAmount,
  }) : super(key: key);

  @override
  State<ChangeCalculatorDialog> createState() => _ChangeCalculatorDialogState();
}

class _ChangeCalculatorDialogState extends State<ChangeCalculatorDialog> {
  final TextEditingController _receivedController = TextEditingController();
  double _changeAmount = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _receivedController.addListener(_calculateChange);
  }

  @override
  void dispose() {
    _receivedController.removeListener(_calculateChange);
    _receivedController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final text = _receivedController.text;
    if (text.isEmpty) {
      setState(() {
        _changeAmount = 0.0;
        _errorMessage = null;
      });
      return;
    }

    final received =
        double.tryParse(text.replaceAll('\$', '').replaceAll(',', ''));
    if (received == null) {
      setState(() {
        _errorMessage = "Please enter a valid amount";
        _changeAmount = 0.0;
      });
    } else if (received < widget.paymentAmount) {
      setState(() {
        _errorMessage = "Received amount is less than payment amount";
        _changeAmount = 0.0;
      });
    } else {
      setState(() {
        _errorMessage = null;
        _changeAmount = received - widget.paymentAmount;
      });
    }
  }

  List<Map<String, dynamic>> _calculateDenominations(double amount) {
    final denominations = [
      {"value": 100.0, "label": "\$100 Bills", "type": "bill"},
      {"value": 50.0, "label": "\$50 Bills", "type": "bill"},
      {"value": 20.0, "label": "\$20 Bills", "type": "bill"},
      {"value": 10.0, "label": "\$10 Bills", "type": "bill"},
      {"value": 5.0, "label": "\$5 Bills", "type": "bill"},
      {"value": 1.0, "label": "\$1 Bills", "type": "bill"},
      {"value": 0.25, "label": "Quarters", "type": "coin"},
      {"value": 0.10, "label": "Dimes", "type": "coin"},
      {"value": 0.05, "label": "Nickels", "type": "coin"},
      {"value": 0.01, "label": "Pennies", "type": "coin"},
    ];

    List<Map<String, dynamic>> breakdown = [];
    double remaining = amount;

    for (var denom in denominations) {
      final count = (remaining / (denom["value"] as double)).floor();
      if (count > 0) {
        breakdown.add({
          "label": denom["label"],
          "count": count,
          "value": denom["value"],
          "total": count * (denom["value"] as double),
          "type": denom["type"],
        });
        remaining = (remaining - (count * (denom["value"] as double))).abs();
        if (remaining < 0.01) break;
      }
    }

    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final breakdown = _changeAmount > 0
        ? _calculateDenominations(_changeAmount)
        : <Map<String, dynamic>>[];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        constraints: BoxConstraints(
          maxHeight: 80.h,
          maxWidth: 90.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'calculate',
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    "Change Calculator",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: isLight
                        ? AppTheme.onSurfaceVariantLight
                        : AppTheme.onSurfaceVariantDark,
                    size: 24,
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Payment Amount Display
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Amount",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "\$${widget.paymentAmount.toStringAsFixed(2)}",
                    style: AppTheme.dataTextStyleEmphasis(
                      isLight: isLight,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ).copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Cash Received Input
            Text(
              "Cash Received",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 1.h),

            TextFormField(
              controller: _receivedController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: "0.00",
                prefixText: "\$ ",
                errorText: _errorMessage,
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'payments',
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              autofocus: true,
            ),

            SizedBox(height: 3.h),

            // Change Amount Display
            if (_changeAmount > 0) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color:
                      AppTheme.getSuccessColor(isLight).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.getSuccessColor(isLight)
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'trending_up',
                          color: AppTheme.getSuccessColor(isLight),
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "Change to Return",
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.getSuccessColor(isLight),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "\$${_changeAmount.toStringAsFixed(2)}",
                      style: AppTheme.dataTextStyleEmphasis(
                        isLight: isLight,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ).copyWith(
                        color: AppTheme.getSuccessColor(isLight),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Denomination Breakdown
              if (breakdown.isNotEmpty) ...[
                Text(
                  "Suggested Breakdown",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 1.h),
                Container(
                  constraints: BoxConstraints(maxHeight: 25.h),
                  child: SingleChildScrollView(
                    child: Column(
                      children: breakdown.map((item) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceVariant(isLight),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.getOutlineColor(isLight),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: item["type"] == "bill"
                                    ? 'receipt'
                                    : 'monetization_on',
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  item["label"],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                "${item["count"]}x",
                                style: AppTheme.dataTextStyle(
                                  isLight: isLight,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "\$${item["total"].toStringAsFixed(2)}",
                                style: AppTheme.dataTextStyle(
                                  isLight: isLight,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],

            SizedBox(height: 3.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                ),
                if (_changeAmount > 0) ...[
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Copy change amount to clipboard or perform other action
                        Navigator.pop(context, _changeAmount);
                      },
                      child: Text("Confirm"),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}