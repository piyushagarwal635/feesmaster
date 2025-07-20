import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentPreferencesStepWidget extends StatefulWidget {
  final Map<String, dynamic> studentData;
  final Function(Map<String, dynamic>) onDataChanged;

  const PaymentPreferencesStepWidget({
    Key? key,
    required this.studentData,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<PaymentPreferencesStepWidget> createState() =>
      _PaymentPreferencesStepWidgetState();
}

class _PaymentPreferencesStepWidgetState
    extends State<PaymentPreferencesStepWidget> {
  final _initialPaymentController = TextEditingController();
  String _selectedInstallmentOption = 'monthly';
  DateTime? _selectedDueDate;
  bool _recordInitialPayment = false;

  final List<Map<String, dynamic>> _installmentOptions = [
    {
      'id': 'full',
      'name': 'Full Payment',
      'description': 'Pay the entire fee at once',
      'icon': 'payment',
      'installments': 1,
    },
    {
      'id': 'monthly',
      'name': 'Monthly Installments',
      'description': 'Split into monthly payments',
      'icon': 'calendar_month',
      'installments': 6,
    },
    {
      'id': 'quarterly',
      'name': 'Quarterly Installments',
      'description': 'Split into quarterly payments',
      'icon': 'date_range',
      'installments': 4,
    },
    {
      'id': 'custom',
      'name': 'Custom Plan',
      'description': 'Create a custom payment schedule',
      'icon': 'tune',
      'installments': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _selectedInstallmentOption =
        widget.studentData['installmentOption'] ?? 'monthly';
    _recordInitialPayment = widget.studentData['recordInitialPayment'] ?? false;
    _initialPaymentController.text =
        widget.studentData['initialPayment']?.toString() ?? '';

    if (widget.studentData['dueDate'] != null) {
      _selectedDueDate = DateTime.parse(widget.studentData['dueDate']);
    }
  }

  void _updateStudentData() {
    final updatedData = {
      ...widget.studentData,
      'installmentOption': _selectedInstallmentOption,
      'recordInitialPayment': _recordInitialPayment,
      'initialPayment': _initialPaymentController.text.isNotEmpty
          ? double.tryParse(_initialPaymentController.text)
          : null,
      'dueDate': _selectedDueDate?.toIso8601String(),
    };
    widget.onDataChanged(updatedData);
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return DatePickerTheme(
          data: DatePickerThemeData(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            headerBackgroundColor: AppTheme.lightTheme.primaryColor,
            headerForegroundColor: Colors.white,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return null;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.lightTheme.primaryColor;
              }
              return null;
            }),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
      _updateStudentData();
    }
  }

  double _calculateInstallmentAmount() {
    final courseFee = widget.studentData['courseFee'] as double? ?? 0.0;
    final option = _installmentOptions.firstWhere(
      (opt) => opt['id'] == _selectedInstallmentOption,
      orElse: () => _installmentOptions[1],
    );

    if (option['installments'] == 1) {
      return courseFee;
    } else if (option['installments'] > 1) {
      return courseFee / option['installments'];
    }
    return 0.0;
  }

  @override
  void dispose() {
    _initialPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final courseFee = widget.studentData['courseFee'] as double? ?? 0.0;
    final installmentAmount = _calculateInstallmentAmount();

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Preferences',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 3.h),

          // Course Fee Display
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Course Fee',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      widget.studentData['course'] ?? 'Selected Course',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                    ),
                  ],
                ),
                Text(
                  '\$${courseFee.toStringAsFixed(2)}',
                  style: AppTheme.dataTextStyleEmphasis(
                    isLight: isLight,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Installment Options
          Text(
            'Payment Plan *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),

          ..._installmentOptions.map((option) {
            final isSelected = _selectedInstallmentOption == option['id'];

            return Container(
              margin: EdgeInsets.only(bottom: 1.h),
              child: Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                    : AppTheme.getSurfaceVariant(isLight),
                child: ListTile(
                  contentPadding: EdgeInsets.all(3.w),
                  leading: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.getOutlineColor(isLight),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: option['icon'],
                      color: isSelected
                          ? Colors.white
                          : AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    option['name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : null,
                        ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 0.5.h),
                      Text(
                        option['description'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (option['installments'] > 1 && isSelected) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          '${option['installments']} payments of \$${installmentAmount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.getSuccessColor(isLight),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ],
                  ),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 24,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedInstallmentOption = option['id'];
                    });
                    _updateStudentData();
                  },
                ),
              ),
            );
          }).toList(),

          SizedBox(height: 3.h),

          // Due Date Selection
          Text(
            'First Payment Due Date *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),

          GestureDetector(
            onTap: _selectDueDate,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.getOutlineColor(isLight)),
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.getSurfaceVariant(isLight),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDueDate != null
                              ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                              : 'Select due date',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _selectedDueDate != null
                                        ? null
                                        : Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                  ),
                        ),
                        if (_selectedDueDate != null)
                          Text(
                            _getDaysDifference(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.lightTheme.primaryColor,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'arrow_drop_down',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Initial Payment Recording
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceVariant(isLight),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.getOutlineColor(isLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _recordInitialPayment,
                      onChanged: (value) {
                        setState(() {
                          _recordInitialPayment = value ?? false;
                          if (!_recordInitialPayment) {
                            _initialPaymentController.clear();
                          }
                        });
                        _updateStudentData();
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Record Initial Payment',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                    ),
                  ],
                ),
                if (_recordInitialPayment) ...[
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _initialPaymentController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Initial Payment Amount',
                      hintText: 'Enter amount',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'attach_money',
                          color: AppTheme.getSuccessColor(isLight),
                          size: 20,
                        ),
                      ),
                      suffixText: 'USD',
                    ),
                    validator: (value) {
                      if (_recordInitialPayment &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter initial payment amount';
                      }
                      if (value != null && value.isNotEmpty) {
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        if (amount > courseFee) {
                          return 'Amount cannot exceed course fee';
                        }
                      }
                      return null;
                    },
                    onChanged: (value) => _updateStudentData(),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'This amount will be recorded as the first payment',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.getSuccessColor(isLight),
                        ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Payment Summary
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.getSuccessColor(isLight).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.getSuccessColor(isLight).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'summarize',
                      color: AppTheme.getSuccessColor(isLight),
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Payment Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getSuccessColor(isLight),
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildSummaryRow(
                    'Total Fee:', '\$${courseFee.toStringAsFixed(2)}'),
                if (_recordInitialPayment &&
                    _initialPaymentController.text.isNotEmpty) ...[
                  _buildSummaryRow('Initial Payment:',
                      '-\$${double.tryParse(_initialPaymentController.text)?.toStringAsFixed(2) ?? '0.00'}'),
                  Divider(
                      color: AppTheme.getSuccessColor(isLight)
                          .withValues(alpha: 0.3)),
                  _buildSummaryRow(
                    'Remaining Balance:',
                    '\$${(courseFee - (double.tryParse(_initialPaymentController.text) ?? 0.0)).toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
                if (_selectedInstallmentOption != 'full' &&
                    _selectedInstallmentOption != 'custom')
                  _buildSummaryRow('Per Installment:',
                      '\$${installmentAmount.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
          Text(
            value,
            style: AppTheme.dataTextStyle(
              isLight: Theme.of(context).brightness == Brightness.light,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getDaysDifference() {
    if (_selectedDueDate == null) return '';

    final now = DateTime.now();
    final difference = _selectedDueDate!.difference(now).inDays;

    if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference > 1) {
      return 'Due in $difference days';
    } else {
      return 'Overdue by ${difference.abs()} days';
    }
  }
}
