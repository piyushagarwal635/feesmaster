import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentFormSection extends StatefulWidget {
  final TextEditingController amountController;
  final TextEditingController referenceController;
  final TextEditingController notesController;
  final String selectedPaymentMethod;
  final DateTime selectedDate;
  final String? selectedInstallment;
  final double maxAmount;
  final Function(String) onPaymentMethodChanged;
  final Function(DateTime) onDateChanged;
  final Function(String?) onInstallmentChanged;
  final VoidCallback onCalculateChange;

  const PaymentFormSection({
    Key? key,
    required this.amountController,
    required this.referenceController,
    required this.notesController,
    required this.selectedPaymentMethod,
    required this.selectedDate,
    required this.selectedInstallment,
    required this.maxAmount,
    required this.onPaymentMethodChanged,
    required this.onDateChanged,
    required this.onInstallmentChanged,
    required this.onCalculateChange,
  }) : super(key: key);

  @override
  State<PaymentFormSection> createState() => _PaymentFormSectionState();
}

class _PaymentFormSectionState extends State<PaymentFormSection> {
  final List<Map<String, dynamic>> paymentMethods = [
    {"value": "cash", "label": "Cash", "icon": "payments"},
    {"value": "card", "label": "Card", "icon": "credit_card"},
    {"value": "online", "label": "Online", "icon": "computer"},
    {"value": "check", "label": "Check", "icon": "receipt_long"},
  ];

  final List<String> installmentOptions = [
    "1st Installment",
    "2nd Installment",
    "3rd Installment",
    "4th Installment",
    "Full Payment"
  ];

  String? _amountError;

  @override
  void initState() {
    super.initState();
    widget.amountController.addListener(_validateAmount);
  }

  @override
  void dispose() {
    widget.amountController.removeListener(_validateAmount);
    super.dispose();
  }

  void _validateAmount() {
    final text = widget.amountController.text;
    if (text.isEmpty) {
      setState(() => _amountError = null);
      return;
    }

    final amount =
        double.tryParse(text.replaceAll('\$', '').replaceAll(',', ''));
    if (amount == null) {
      setState(() => _amountError = "Please enter a valid amount");
    } else if (amount <= 0) {
      setState(() => _amountError = "Amount must be greater than zero");
    } else if (amount > widget.maxAmount) {
      setState(() => _amountError = "Amount cannot exceed outstanding balance");
    } else {
      setState(() => _amountError = null);
    }
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              headerBackgroundColor: Theme.of(context).colorScheme.primary,
              headerForegroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateChanged(picked);
    }
  }

  void _showInstallmentPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Installment",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),
              ...installmentOptions
                  .map((option) => ListTile(
                        title: Text(option),
                        onTap: () {
                          widget.onInstallmentChanged(option);
                          Navigator.pop(context);
                        },
                        trailing: widget.selectedInstallment == option
                            ? CustomIconWidget(
                                iconName: 'check',
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              )
                            : null,
                      ))
                  .toList(),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  void _showQuickAmountOptions() {
    final quickAmounts = [
      widget.maxAmount,
      widget.maxAmount / 2,
      widget.maxAmount / 4,
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quick Amount Selection",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                title: Text("Full Amount"),
                subtitle: Text("\$${quickAmounts[0].toStringAsFixed(2)}"),
                onTap: () {
                  widget.amountController.text =
                      quickAmounts[0].toStringAsFixed(2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Half Payment"),
                subtitle: Text("\$${quickAmounts[1].toStringAsFixed(2)}"),
                onTap: () {
                  widget.amountController.text =
                      quickAmounts[1].toStringAsFixed(2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Quarter Payment"),
                subtitle: Text("\$${quickAmounts[2].toStringAsFixed(2)}"),
                onTap: () {
                  widget.amountController.text =
                      quickAmounts[2].toStringAsFixed(2);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceVariant(isLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getOutlineColor(isLight),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount Field
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Amount *",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: widget.amountController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        hintText: "0.00",
                        prefixText: "\$ ",
                        errorText: _amountError,
                        suffixIcon: IconButton(
                          onPressed: _showQuickAmountOptions,
                          icon: CustomIconWidget(
                            iconName: 'keyboard_arrow_down',
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.selectedPaymentMethod == "cash") ...[
                SizedBox(width: 4.w),
                ElevatedButton(
                  onPressed: widget.onCalculateChange,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  ),
                  child: Text("Change", style: TextStyle(fontSize: 12.sp)),
                ),
              ],
            ],
          ),

          SizedBox(height: 3.h),

          // Payment Method Selection
          Text(
            "Payment Method *",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),

          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: paymentMethods.map((method) {
              final isSelected =
                  widget.selectedPaymentMethod == method["value"];
              return GestureDetector(
                onTap: () => widget.onPaymentMethodChanged(method["value"]),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : AppTheme.getOutlineColor(isLight),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: method["icon"],
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (isLight
                                ? AppTheme.onSurfaceVariantLight
                                : AppTheme.onSurfaceVariantDark),
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        method["label"],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 3.h),

          // Date Selection
          Text(
            "Payment Date *",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),

          GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.getOutlineColor(isLight),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    "${widget.selectedDate.month.toString().padLeft(2, '0')}/${widget.selectedDate.day.toString().padLeft(2, '0')}/${widget.selectedDate.year}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Spacer(),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: isLight
                        ? AppTheme.onSurfaceVariantLight
                        : AppTheme.onSurfaceVariantDark,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Installment Selection
          Text(
            "Installment Allocation",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),

          GestureDetector(
            onTap: _showInstallmentPicker,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.getOutlineColor(isLight),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'account_balance',
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    widget.selectedInstallment ?? "Select Installment",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.selectedInstallment == null
                              ? (isLight
                                  ? AppTheme.onSurfaceVariantLight
                                  : AppTheme.onSurfaceVariantDark)
                              : null,
                        ),
                  ),
                  Spacer(),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: isLight
                        ? AppTheme.onSurfaceVariantLight
                        : AppTheme.onSurfaceVariantDark,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Transaction Reference
          Text(
            "Transaction Reference",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),

          TextFormField(
            controller: widget.referenceController,
            decoration: InputDecoration(
              hintText: "Enter reference number (optional)",
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'receipt',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Notes
          Text(
            "Notes",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),

          TextFormField(
            controller: widget.notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Add any additional notes (optional)",
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'note',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
