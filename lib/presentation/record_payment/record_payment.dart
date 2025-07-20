import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/change_calculator_dialog.dart';
import './widgets/payment_form_section.dart';
import './widgets/receipt_camera_section.dart';
import './widgets/student_info_card.dart';

class RecordPayment extends StatefulWidget {
  const RecordPayment({Key? key}) : super(key: key);

  @override
  State<RecordPayment> createState() => _RecordPaymentState();
}

class _RecordPaymentState extends State<RecordPayment> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedPaymentMethod = "cash";
  DateTime _selectedDate = DateTime.now();
  String? _selectedInstallment;
  XFile? _receiptImage;
  bool _isProcessing = false;
  bool _isDraftSaved = false;

  // Mock student data
  final Map<String, dynamic> _studentData = {
    "id": 1,
    "studentId": "STU001",
    "name": "Emily Johnson",
    "photo":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
    "outstandingAmount": 1250.00,
    "course": "Advanced Mathematics",
    "batch": "Morning Batch A",
    "enrollmentDate": "2024-01-15",
    "totalFees": 2500.00,
    "paidAmount": 1250.00,
    "installments": [
      {
        "number": 1,
        "amount": 625.00,
        "dueDate": "2024-02-15",
        "status": "paid"
      },
      {
        "number": 2,
        "amount": 625.00,
        "dueDate": "2024-03-15",
        "status": "paid"
      },
      {
        "number": 3,
        "amount": 625.00,
        "dueDate": "2024-04-15",
        "status": "pending"
      },
      {
        "number": 4,
        "amount": 625.00,
        "dueDate": "2024-05-15",
        "status": "pending"
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    _loadDraftData();
    _amountController.addListener(_saveDraft);
    _referenceController.addListener(_saveDraft);
    _notesController.addListener(_saveDraft);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadDraftData() {
    // Simulate loading draft data from local storage
    // In real implementation, use SharedPreferences or secure storage
  }

  void _saveDraft() {
    if (!_isDraftSaved) {
      setState(() => _isDraftSaved = true);
      // Simulate auto-save functionality
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isDraftSaved = false);
        }
      });
    }
  }

  bool _isFormValid() {
    final amount = double.tryParse(
        _amountController.text.replaceAll('\$', '').replaceAll(',', ''));
    return amount != null &&
        amount > 0 &&
        amount <= (_studentData["outstandingAmount"] as double) &&
        _selectedPaymentMethod.isNotEmpty;
  }

  void _onPaymentMethodChanged(String method) {
    setState(() => _selectedPaymentMethod = method);
    _saveDraft();
  }

  void _onDateChanged(DateTime date) {
    setState(() => _selectedDate = date);
    _saveDraft();
  }

  void _onInstallmentChanged(String? installment) {
    setState(() => _selectedInstallment = installment);
    _saveDraft();
  }

  void _onImageCaptured(XFile? image) {
    setState(() => _receiptImage = image);
  }

  void _onCalculateChange() async {
    final amount = double.tryParse(
        _amountController.text.replaceAll('\$', '').replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      _showSnackBar("Please enter a valid payment amount first", isError: true);
      return;
    }

    final result = await showDialog<double>(
      context: context,
      builder: (context) => ChangeCalculatorDialog(paymentAmount: amount),
    );

    if (result != null) {
      _showSnackBar("Change calculated: \$${result.toStringAsFixed(2)}",
          isError: false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _recordPayment() async {
    if (!_isFormValid()) {
      _showSnackBar("Please fill in all required fields correctly",
          isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 2));

      // Simulate payment recording
      final amount = double.parse(
          _amountController.text.replaceAll('\$', '').replaceAll(',', ''));
      final paymentData = {
        "studentId": _studentData["studentId"],
        "amount": amount,
        "paymentMethod": _selectedPaymentMethod,
        "date": _selectedDate.toIso8601String(),
        "installment": _selectedInstallment,
        "reference": _referenceController.text,
        "notes": _notesController.text,
        "receiptImage": _receiptImage?.path,
        "timestamp": DateTime.now().toIso8601String(),
      };

      // Trigger haptic feedback
      HapticFeedback.lightImpact();

      // Show success and generate receipt
      _showSuccessDialog(paymentData);
    } catch (e) {
      _showSnackBar("Failed to record payment. Please try again.",
          isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> paymentData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check',
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Payment Recorded Successfully!",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              "Amount: \$${(paymentData["amount"] as double).toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Receipt generated and ready to share",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _shareReceipt(paymentData);
            },
            child: Text("Share Receipt"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
            },
            child: Text("Done"),
          ),
        ],
      ),
    );
  }

  void _shareReceipt(Map<String, dynamic> paymentData) {
    // Simulate receipt sharing options
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Share Receipt",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'sms',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text("Send SMS"),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar("SMS sent successfully", isError: false);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text("Send Email"),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar("Email sent successfully", isError: false);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'print',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text("Print Receipt"),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar("Printing receipt...", isError: false);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Record Payment"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color:
                Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
            size: 24,
          ),
        ),
        actions: [
          if (_isDraftSaved)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'save',
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        "Draft Saved",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Student Information Card
                  StudentInfoCard(studentData: _studentData),

                  SizedBox(height: 2.h),

                  // Payment Form Section
                  PaymentFormSection(
                    amountController: _amountController,
                    referenceController: _referenceController,
                    notesController: _notesController,
                    selectedPaymentMethod: _selectedPaymentMethod,
                    selectedDate: _selectedDate,
                    selectedInstallment: _selectedInstallment,
                    maxAmount: _studentData["outstandingAmount"] as double,
                    onPaymentMethodChanged: _onPaymentMethodChanged,
                    onDateChanged: _onDateChanged,
                    onInstallmentChanged: _onInstallmentChanged,
                    onCalculateChange: _onCalculateChange,
                  ),

                  SizedBox(height: 2.h),

                  // Receipt Camera Section
                  ReceiptCameraSection(
                    onImageCaptured: _onImageCaptured,
                  ),

                  SizedBox(height: 10.h), // Space for sticky button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: AppTheme.getOutlineColor(isLight),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed:
                  _isFormValid() && !_isProcessing ? _recordPayment : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "Processing...",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'payment',
                          color: _isFormValid()
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "Record Payment",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
