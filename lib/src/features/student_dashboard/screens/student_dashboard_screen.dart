import 'package:flutter/material.dart';
class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Student Dashboard")), body: Center(child: Text("Chào mừng Học sinh!")));
  }
}