import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/alert_card_widget.dart';
import './widgets/collection_chart_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_payment_card_widget.dart';
import './widgets/stats_card_widget.dart';

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  DateTime _lastSyncTime = DateTime.now().subtract(Duration(minutes: 5));

  // Mock data for dashboard
  final List<Map<String, dynamic>> recentPayments = [
    {
      "studentName": "Sarah Johnson",
      "course": "Mathematics Advanced",
      "amount": "\$450.00",
      "status": "paid",
      "date": "Today, 2:30 PM",
      "receiptId": "RCP-2024-001",
    },
    {
      "studentName": "Michael Chen",
      "course": "Physics Premium",
      "amount": "\$380.00",
      "status": "pending",
      "date": "Today, 1:15 PM",
      "receiptId": "RCP-2024-002",
    },
    {
      "studentName": "Emma Rodriguez",
      "course": "Chemistry Basic",
      "amount": "\$320.00",
      "status": "overdue",
      "date": "Yesterday, 4:45 PM",
      "receiptId": "RCP-2024-003",
    },
    {
      "studentName": "David Thompson",
      "course": "Biology Advanced",
      "amount": "\$420.00",
      "status": "paid",
      "date": "Yesterday, 11:20 AM",
      "receiptId": "RCP-2024-004",
    },
  ];

  final List<Map<String, dynamic>> urgentAlerts = [
    {
      "title": "Overdue Payments Alert",
      "message": "8 students have payments overdue by more than 7 days",
      "priority": "high",
      "time": "2 hours ago",
      "count": 8,
    },
    {
      "title": "Payment Due Today",
      "message": "12 students have payments due today",
      "priority": "medium",
      "time": "4 hours ago",
      "count": 12,
    },
    {
      "title": "New Enrollment Pending",
      "message": "3 new student applications require fee structure setup",
      "priority": "low",
      "time": "6 hours ago",
      "count": 3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(context, isDark),
          _buildPlaceholderTab('Students'),
          _buildPlaceholderTab('Payments'),
          _buildPlaceholderTab('Reports'),
          _buildPlaceholderTab('Profile'),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, isDark),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'account_balance',
            color: Colors.white,
            size: 6.w,
          ),
          SizedBox(width: 2.w),
          Text(
            'FeesMaster',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'wifi',
                color: Colors.white,
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                'Synced',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _showSyncStatus(context),
          icon: CustomIconWidget(
            iconName: 'sync',
            color: Colors.white,
            size: 6.w,
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: Theme.of(context).tabBarTheme.labelColor,
              size: 5.w,
            ),
            text: 'Dashboard',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'people',
              color: Theme.of(context).tabBarTheme.unselectedLabelColor,
              size: 5.w,
            ),
            text: 'Students',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'payment',
              color: Theme.of(context).tabBarTheme.unselectedLabelColor,
              size: 5.w,
            ),
            text: 'Payments',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'assessment',
              color: Theme.of(context).tabBarTheme.unselectedLabelColor,
              size: 5.w,
            ),
            text: 'Reports',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'person',
              color: Theme.of(context).tabBarTheme.unselectedLabelColor,
              size: 5.w,
            ),
            text: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context, bool isDark) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStickyHeader(context, isDark),
            SizedBox(height: 3.h),
            _buildQuickStats(context, isDark),
            SizedBox(height: 3.h),
            CollectionChartWidget(),
            SizedBox(height: 3.h),
            _buildRecentPayments(context),
            SizedBox(height: 3.h),
            _buildUrgentAlerts(context),
            SizedBox(height: 3.h),
            QuickActionsWidget(),
            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Collections',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Last synced: ${_formatSyncTime()}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '\$2,450.00',
            style: AppTheme.dataTextStyleEmphasis(
              isLight: true,
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
            ).copyWith(color: Colors.white),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'trending_up',
                color: Colors.white,
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                '+12.5% from yesterday',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatsCardWidget(
              title: 'Pending Dues',
              value: '\$8,750',
              subtitle: '25 students',
              valueColor: AppTheme.getWarningColor(isDark == false),
              iconName: 'schedule',
              onTap: () => Navigator.pushNamed(context, '/student-list'),
            ),
            StatsCardWidget(
              title: 'Overdue',
              value: '\$3,200',
              subtitle: '8 students',
              valueColor: AppTheme.getErrorColor(isDark == false),
              iconName: 'error',
              onTap: () => Navigator.pushNamed(context, '/student-list'),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatsCardWidget(
              title: 'New Enrollments',
              value: '12',
              subtitle: 'This month',
              valueColor: AppTheme.getSuccessColor(isDark == false),
              iconName: 'person_add',
              onTap: () => Navigator.pushNamed(context, '/add-new-student'),
            ),
            StatsCardWidget(
              title: 'Total Students',
              value: '156',
              subtitle: 'Active',
              valueColor: Theme.of(context).colorScheme.primary,
              iconName: 'people',
              onTap: () => Navigator.pushNamed(context, '/student-list'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentPayments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Payments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/student-list'),
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 20.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentPayments.length,
            itemBuilder: (context, index) {
              return RecentPaymentCardWidget(
                payment: recentPayments[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentAlerts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urgent Alerts',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
        ),
        SizedBox(height: 2.h),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: urgentAlerts.length,
          itemBuilder: (context, index) {
            return AlertCardWidget(
              alert: urgentAlerts[index],
              onTap: () => Navigator.pushNamed(context, '/student-list'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'construction',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            '$tabName Coming Soon',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.getOutlineColor(isDark == false)
                .withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('Dashboard', 'dashboard', 0),
              _buildNavItem('Students', 'people', 1),
              _buildNavItem('Payments', 'payment', 2),
              _buildNavItem('Reports', 'assessment', 3),
              _buildNavItem('Profile', 'person', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, String iconName, int index) {
    final isSelected = _tabController.index == index;
    final color = isSelected
        ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
        : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor;

    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 6.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickActionsBottomSheet(context),
      icon: CustomIconWidget(
        iconName: 'add',
        color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        size: 6.w,
      ),
      label: Text(
        'Quick Actions',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastSyncTime = DateTime.now();
    });
  }

  void _showSyncStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sync Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.getSuccessColor(
                      Theme.of(context).brightness == Brightness.light),
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text('All data synchronized'),
              ],
            ),
            SizedBox(height: 2.h),
            Text('Last sync: ${_formatSyncTime()}'),
            SizedBox(height: 1.h),
            Text('Next sync: In 10 minutes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRefresh();
            },
            child: Text('Sync Now'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'payment',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Record Payment'),
              subtitle: Text('Add new payment entry'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/record-payment');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person_add',
                color: AppTheme.getSuccessColor(
                    Theme.of(context).brightness == Brightness.light),
                size: 6.w,
              ),
              title: Text('Add New Student'),
              subtitle: Text('Enroll a new student'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-new-student');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.getWarningColor(
                    Theme.of(context).brightness == Brightness.light),
                size: 6.w,
              ),
              title: Text('Send Reminders'),
              subtitle: Text('Notify students about dues'),
              onTap: () {
                Navigator.pop(context);
                _showReminderDialog(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'people',
                color: Theme.of(context).colorScheme.secondary,
                size: 6.w,
              ),
              title: Text('View All Students'),
              subtitle: Text('Browse student list'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/student-list');
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Payment Reminders'),
        content: Text(
            'Send reminder notifications to students with pending payments?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reminders sent successfully!'),
                  backgroundColor: AppTheme.getSuccessColor(
                      Theme.of(context).brightness == Brightness.light),
                ),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  String _formatSyncTime() {
    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
