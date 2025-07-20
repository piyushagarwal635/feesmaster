import 'package:flutter/material.dart';
import '../presentation/admin_login/admin_login.dart';
import '../presentation/dashboard_overview/dashboard_overview.dart';
import '../presentation/student_list/student_list.dart';
import '../presentation/record_payment/record_payment.dart';
import '../presentation/add_new_student/add_new_student.dart';
import '../presentation/student_detail/student_detail.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String adminLogin = '/admin-login';
  static const String dashboardOverview = '/dashboard-overview';
  static const String studentList = '/student-list';
  static const String recordPayment = '/record-payment';
  static const String addNewStudent = '/add-new-student';
  static const String studentDetail = '/student-detail';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const AdminLogin(),
    adminLogin: (context) => const AdminLogin(),
    dashboardOverview: (context) => const DashboardOverview(),
    studentList: (context) => const StudentList(),
    recordPayment: (context) => const RecordPayment(),
    addNewStudent: (context) => const AddNewStudent(),
    studentDetail: (context) => const StudentDetail(),
    // TODO: Add your other routes here
  };
}
