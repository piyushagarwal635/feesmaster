import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/documents_list.dart';
import './widgets/fee_structure_card.dart';
import './widgets/installments_list.dart';
import './widgets/next_due_card.dart';
import './widgets/parent_contact_card.dart';
import './widgets/payment_history_list.dart';
import './widgets/student_profile_header.dart';

class StudentDetail extends StatefulWidget {
  const StudentDetail({Key? key}) : super(key: key);

  @override
  State<StudentDetail> createState() => _StudentDetailState();
}

class _StudentDetailState extends State<StudentDetail>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Mock student data
  final Map<String, dynamic> studentData = {
    "id": 1,
    "name": "Emily Rodriguez",
    "profileImage":
        "https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400",
    "course": "Advanced Mathematics & Physics",
    "phone": "+1 (555) 123-4567",
    "email": "emily.rodriguez@email.com",
    "status": "pending",
    "totalPaid": "\$2,400.00",
    "pendingAmount": "\$800.00",
    "enrollmentDate": "2024-01-15T00:00:00.000Z",
    "studentId": "STU-2024-001"
  };

  final Map<String, dynamic> feeStructure = {
    "type": "Monthly",
    "courseFee": "\$250.00",
    "registrationFee": "\$100.00",
    "materialFee": "\$50.00",
    "labFee": "\$75.00",
    "totalAmount": "\$3,200.00",
    "paymentMode": "Monthly Installments",
    "installments": 12
  };

  final Map<String, dynamic> nextDueInfo = {
    "dueDate": "2024-08-25T00:00:00.000Z",
    "amount": "\$275.00",
    "installmentNumber": 8
  };

  final List<Map<String, dynamic>> paymentHistory = [
    {
      "id": 1,
      "description": "July 2024 - Course Fee",
      "amount": "\$275.00",
      "date": "2024-07-15T10:30:00.000Z",
      "status": "completed",
      "method": "Card",
      "transactionId": "TXN-2024-07-001"
    },
    {
      "id": 2,
      "description": "June 2024 - Course Fee",
      "amount": "\$275.00",
      "date": "2024-06-15T14:20:00.000Z",
      "status": "completed",
      "method": "Bank",
      "transactionId": "TXN-2024-06-001"
    },
    {
      "id": 3,
      "description": "May 2024 - Course Fee",
      "amount": "\$275.00",
      "date": "2024-05-15T09:45:00.000Z",
      "status": "completed",
      "method": "Cash",
      "transactionId": "TXN-2024-05-001"
    },
    {
      "id": 4,
      "description": "April 2024 - Course Fee",
      "amount": "\$275.00",
      "date": "2024-04-15T16:10:00.000Z",
      "status": "completed",
      "method": "Online",
      "transactionId": "TXN-2024-04-001"
    }
  ];

  final List<Map<String, dynamic>> installments = [
    {
      "id": 1,
      "installmentNumber": 1,
      "amount": "\$275.00",
      "dueDate": "2024-01-15T00:00:00.000Z",
      "status": "paid",
      "paidDate": "2024-01-15T10:30:00.000Z",
      "paymentMethod": "Cash"
    },
    {
      "id": 2,
      "installmentNumber": 2,
      "amount": "\$275.00",
      "dueDate": "2024-02-15T00:00:00.000Z",
      "status": "paid",
      "paidDate": "2024-02-14T14:20:00.000Z",
      "paymentMethod": "Card"
    },
    {
      "id": 3,
      "installmentNumber": 3,
      "amount": "\$275.00",
      "dueDate": "2024-03-15T00:00:00.000Z",
      "status": "paid",
      "paidDate": "2024-03-15T09:45:00.000Z",
      "paymentMethod": "Bank"
    },
    {
      "id": 4,
      "installmentNumber": 4,
      "amount": "\$275.00",
      "dueDate": "2024-04-15T00:00:00.000Z",
      "status": "paid",
      "paidDate": "2024-04-15T16:10:00.000Z",
      "paymentMethod": "Online"
    },
    {
      "id": 5,
      "installmentNumber": 5,
      "amount": "\$275.00",
      "dueDate": "2024-05-15T00:00:00.000Z",
      "status": "paid",
      "paidDate": "2024-05-15T09:45:00.000Z",
      "paymentMethod": "Cash"
    },
    {
      "id": 6,
      "installmentNumber": 6,
      "amount": "\$275.00",
      "dueDate": "2024-06-15T00:00:00.000Z",
      "status": "paid",
      "paidDate": "2024-06-15T14:20:00.000Z",
      "paymentMethod": "Bank"
    },
    {
      "id": 7,
      "installmentNumber": 7,
      "amount": "\$275.00",
      "dueDate": "2024-07-15T00:00:00.000Z",
      "status": "paid",
      "paidDate": "2024-07-15T10:30:00.000Z",
      "paymentMethod": "Card"
    },
    {
      "id": 8,
      "installmentNumber": 8,
      "amount": "\$275.00",
      "dueDate": "2024-08-25T00:00:00.000Z",
      "status": "pending"
    },
    {
      "id": 9,
      "installmentNumber": 9,
      "amount": "\$275.00",
      "dueDate": "2024-09-15T00:00:00.000Z",
      "status": "pending"
    },
    {
      "id": 10,
      "installmentNumber": 10,
      "amount": "\$275.00",
      "dueDate": "2024-10-15T00:00:00.000Z",
      "status": "pending"
    },
    {
      "id": 11,
      "installmentNumber": 11,
      "amount": "\$275.00",
      "dueDate": "2024-11-15T00:00:00.000Z",
      "status": "pending"
    },
    {
      "id": 12,
      "installmentNumber": 12,
      "amount": "\$275.00",
      "dueDate": "2024-12-15T00:00:00.000Z",
      "status": "pending"
    }
  ];

  final List<Map<String, dynamic>> documents = [
    {
      "id": 1,
      "name": "Admission Form.pdf",
      "type": "pdf",
      "size": "2.4 MB",
      "uploadDate": "2024-01-15T10:30:00.000Z"
    },
    {
      "id": 2,
      "name": "ID Proof.jpg",
      "type": "jpg",
      "size": "1.8 MB",
      "uploadDate": "2024-01-15T10:35:00.000Z"
    },
    {
      "id": 3,
      "name": "Previous Certificates.pdf",
      "type": "pdf",
      "size": "3.2 MB",
      "uploadDate": "2024-01-20T14:20:00.000Z"
    },
    {
      "id": 4,
      "name": "Medical Certificate.pdf",
      "type": "pdf",
      "size": "1.1 MB",
      "uploadDate": "2024-02-01T09:15:00.000Z"
    }
  ];

  final Map<String, dynamic> parentInfo = {
    "name": "Maria Rodriguez",
    "relationship": "Mother",
    "phone": "+1 (555) 987-6543",
    "email": "maria.rodriguez@email.com",
    "address": "123 Oak Street, Springfield, IL 62701"
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            StudentProfileHeader(studentData: studentData),
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'dashboard',
                          color: _tabController.index == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text('Overview'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'history',
                          color: _tabController.index == 1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text('History'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: _tabController.index == 2
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text('Installments'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'folder',
                          color: _tabController.index == 3
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text('Documents'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Overview Tab
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 1.h),
                        FeeStructureCard(feeStructure: feeStructure),
                        NextDueCard(dueInfo: nextDueInfo),
                        ParentContactCard(parentInfo: parentInfo),
                        SizedBox(height: 10.h), // Space for FAB
                      ],
                    ),
                  ),
                  // Payment History Tab
                  PaymentHistoryList(paymentHistory: paymentHistory),
                  // Installments Tab
                  InstallmentsList(installments: installments),
                  // Documents Tab
                  DocumentsList(documents: documents),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    String buttonText;
    IconData buttonIcon;
    VoidCallback onPressed;

    switch (_tabController.index) {
      case 0: // Overview
        if (studentData['status'] == 'overdue') {
          buttonText = 'Send Reminder';
          buttonIcon = Icons.notification_important;
          onPressed = () => _sendReminder();
        } else if (studentData['status'] == 'pending') {
          buttonText = 'Record Payment';
          buttonIcon = Icons.payment;
          onPressed = () => Navigator.pushNamed(context, '/record-payment');
        } else {
          buttonText = 'Generate Receipt';
          buttonIcon = Icons.receipt;
          onPressed = () => _generateReceipt();
        }
        break;
      case 1: // Payment History
        buttonText = 'Record Payment';
        buttonIcon = Icons.add;
        onPressed = () => Navigator.pushNamed(context, '/record-payment');
        break;
      case 2: // Installments
        buttonText = 'Record Payment';
        buttonIcon = Icons.payment;
        onPressed = () => Navigator.pushNamed(context, '/record-payment');
        break;
      case 3: // Documents
        buttonText = 'Add Document';
        buttonIcon = Icons.add;
        onPressed = () => _showAddDocumentOptions();
        break;
      default:
        buttonText = 'Record Payment';
        buttonIcon = Icons.payment;
        onPressed = () => Navigator.pushNamed(context, '/record-payment');
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: CustomIconWidget(
        iconName: buttonIcon.toString().split('.').last,
        color: Colors.white,
        size: 5.w,
      ),
      label: Text(buttonText),
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      // In a real app, this would refresh data from the server
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Student data refreshed')),
    );
  }

  void _sendReminder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Payment Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send payment reminder to ${parentInfo['name']}?'),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('SMS reminder sent')),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'message',
                      color: Theme.of(context).colorScheme.primary,
                      size: 4.w,
                    ),
                    label: Text('SMS'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Email reminder sent')),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'email',
                      color: Theme.of(context).colorScheme.primary,
                      size: 4.w,
                    ),
                    label: Text('Email'),
                  ),
                ),
              ],
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

  void _generateReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating receipt...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Show receipt
          },
        ),
      ),
    );
  }

  void _showAddDocumentOptions() {
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
                iconName: 'camera_alt',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Camera opened')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gallery opened')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'folder',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Browse Files'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('File browser opened')),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
