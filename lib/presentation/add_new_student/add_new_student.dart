import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/course_selection_step_widget.dart';
import './widgets/navigation_buttons_widget.dart';
import './widgets/payment_preferences_step_widget.dart';
import './widgets/step_indicator_widget.dart';
import './widgets/student_info_step_widget.dart';

class AddNewStudent extends StatefulWidget {
  const AddNewStudent({Key? key}) : super(key: key);

  @override
  State<AddNewStudent> createState() => _AddNewStudentState();
}

class _AddNewStudentState extends State<AddNewStudent>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 3;
  bool _isLoading = false;

  Map<String, dynamic> _studentData = {
    'name': '',
    'phone': '',
    'email': '',
    'countryCode': '+1',
    'profileImage': null,
    'course': null,
    'batch': null,
    'courseFee': null,
    'courseDuration': null,
    'installmentOption': 'monthly',
    'recordInitialPayment': false,
    'initialPayment': null,
    'dueDate': null,
    'createdAt': DateTime.now().toIso8601String(),
    'status': 'draft',
  };

  // Mock existing students for duplicate detection
  final List<Map<String, dynamic>> _existingStudents = [
    {
      'id': 1,
      'name': 'John Smith',
      'phone': '1234567890',
      'email': 'john.smith@email.com',
      'course': 'Mathematics - Basic',
    },
    {
      'id': 2,
      'name': 'Sarah Johnson',
      'phone': '9876543210',
      'email': 'sarah.j@email.com',
      'course': 'Physics - Foundation',
    },
    {
      'id': 3,
      'name': 'Michael Brown',
      'phone': '5555551234',
      'email': 'mike.brown@email.com',
      'course': 'Chemistry - Organic',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _updateStudentData(Map<String, dynamic> newData) {
    setState(() {
      _studentData = newData;
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _validateStudentInfo();
      case 2:
        return _validateCourseSelection();
      case 3:
        return _validatePaymentPreferences();
      default:
        return false;
    }
  }

  bool _validateStudentInfo() {
    final name = _studentData['name'] as String?;
    final phone = _studentData['phone'] as String?;
    final email = _studentData['email'] as String?;

    if (name == null || name.trim().isEmpty) return false;
    if (phone == null || phone.trim().isEmpty || phone.length < 10)
      return false;
    if (email == null || email.trim().isEmpty || !_isValidEmail(email))
      return false;

    return true;
  }

  bool _validateCourseSelection() {
    final course = _studentData['course'] as String?;
    final batch = _studentData['batch'] as String?;

    return course != null &&
        course.isNotEmpty &&
        batch != null &&
        batch.isNotEmpty;
  }

  bool _validatePaymentPreferences() {
    final installmentOption = _studentData['installmentOption'] as String?;
    final dueDate = _studentData['dueDate'] as String?;
    final recordInitialPayment =
        _studentData['recordInitialPayment'] as bool? ?? false;

    if (installmentOption == null || installmentOption.isEmpty) return false;
    if (dueDate == null || dueDate.isEmpty) return false;

    if (recordInitialPayment) {
      final initialPayment = _studentData['initialPayment'] as double?;
      if (initialPayment == null || initialPayment <= 0) return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    return emailRegex.hasMatch(email);
  }

  bool _checkForDuplicateStudent() {
    final phone = _studentData['phone'] as String? ?? '';
    final email = _studentData['email'] as String? ?? '';

    return _existingStudents.any(
        (student) => student['phone'] == phone || student['email'] == email);
  }

  void _showDuplicateWarning() {
    final phone = _studentData['phone'] as String? ?? '';
    final email = _studentData['email'] as String? ?? '';

    final duplicateStudent = _existingStudents.firstWhere(
      (student) => student['phone'] == phone || student['email'] == email,
      orElse: () => {},
    );

    if (duplicateStudent.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.getWarningColor(
                      Theme.of(context).brightness == Brightness.light),
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text('Duplicate Student Found'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A student with similar details already exists:'),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.getWarningColor(
                            Theme.of(context).brightness == Brightness.light)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${duplicateStudent['name']}'),
                      Text('Phone: ${duplicateStudent['phone']}'),
                      Text('Email: ${duplicateStudent['email']}'),
                      Text('Course: ${duplicateStudent['course']}'),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Text('Do you want to continue with enrollment?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _proceedWithEnrollment();
                },
                child: Text('Continue'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _nextStep() async {
    if (!_validateCurrentStep()) {
      _showValidationError();
      return;
    }

    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
      await _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      await _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveDraft() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      _studentData['status'] = 'draft';
      _studentData['lastModified'] = DateTime.now().toIso8601String();

      Fluttertoast.showToast(
        msg: "Draft saved successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        textColor: Colors.white,
      );
    } catch (e) {
      _showErrorMessage('Failed to save draft. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndFinish() async {
    if (!_validateCurrentStep()) {
      _showValidationError();
      return;
    }

    // Check for duplicates
    if (_checkForDuplicateStudent()) {
      _showDuplicateWarning();
      return;
    }

    _proceedWithEnrollment();
  }

  Future<void> _proceedWithEnrollment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call for student enrollment
      await Future.delayed(Duration(seconds: 2));

      _studentData['status'] = 'enrolled';
      _studentData['studentId'] = 'STU${DateTime.now().millisecondsSinceEpoch}';
      _studentData['enrollmentDate'] = DateTime.now().toIso8601String();

      // Simulate sending welcome SMS/Email
      await _sendWelcomeNotification();

      _showSuccessDialog();
    } catch (e) {
      _showErrorMessage('Failed to enroll student. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendWelcomeNotification() async {
    // Simulate sending welcome notification
    await Future.delayed(Duration(milliseconds: 500));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.getSuccessColor(
                    Theme.of(context).brightness == Brightness.light),
                size: 28,
              ),
              SizedBox(width: 2.w),
              Text('Enrollment Successful!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student has been successfully enrolled.'),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.getSuccessColor(
                          Theme.of(context).brightness == Brightness.light)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student ID: ${_studentData['studentId']}'),
                    Text('Name: ${_studentData['name']}'),
                    Text('Course: ${_studentData['course']}'),
                    Text('Batch: ${_studentData['batch']}'),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Welcome notification sent to student.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.getSuccessColor(
                          Theme.of(context).brightness == Brightness.light),
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/student-list');
              },
              child: Text('View All Students'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/student-detail');
              },
              child: Text('View Student Details'),
            ),
          ],
        );
      },
    );
  }

  void _showValidationError() {
    String message = 'Please complete all required fields in this step.';

    switch (_currentStep) {
      case 1:
        message =
            'Please fill in student name, phone number, and email address.';
        break;
      case 2:
        message = 'Please select a course and batch.';
        break;
      case 3:
        message = 'Please select payment plan and due date.';
        break;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.getWarningColor(
          Theme.of(context).brightness == Brightness.light),
      textColor: Colors.white,
    );
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.getErrorColor(
          Theme.of(context).brightness == Brightness.light),
      textColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Student'),
        leading: IconButton(
          onPressed: () {
            if (_isLoading) return;

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Discard Changes?'),
                  content: Text(
                      'Are you sure you want to leave? Any unsaved changes will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Discard'),
                    ),
                  ],
                );
              },
            );
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 24,
          ),
        ),
        actions: [
          if (_currentStep < _totalSteps)
            TextButton(
              onPressed: _isLoading ? null : _saveDraft,
              child: Text(
                'Save Draft',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Step Indicator
          StepIndicatorWidget(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Student Information
                StudentInfoStepWidget(
                  studentData: _studentData,
                  onDataChanged: _updateStudentData,
                ),

                // Step 2: Course Selection
                CourseSelectionStepWidget(
                  studentData: _studentData,
                  onDataChanged: _updateStudentData,
                ),

                // Step 3: Payment Preferences
                PaymentPreferencesStepWidget(
                  studentData: _studentData,
                  onDataChanged: _updateStudentData,
                ),
              ],
            ),
          ),

          // Navigation Buttons
          NavigationButtonsWidget(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
            onPrevious: _previousStep,
            onNext: _nextStep,
            onSaveDraft: _saveDraft,
            onSaveFinish: _saveAndFinish,
            canProceed: _validateCurrentStep(),
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
