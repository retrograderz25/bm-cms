// lib/src/features/student_dashboard/screens/student_class_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../common/utils/responsive_helper.dart';
import '../../../data/models/class_model.dart';
import '../widgets/student_announcement_tab.dart';
import '../widgets/student_grade_list_tab.dart'; // Sẽ tạo ngay sau đây

class StudentClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;

  const StudentClassDetailScreen({super.key, required this.classModel});

  @override
  State<StudentClassDetailScreen> createState() => _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _tabs;
  late final List<NavigationRailDestination> _destinations;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
  }

  void _initializeTabs() {
    _tabs = [
      StudentGradeListTab(classId: widget.classModel.id), // Tab điểm số
      const Center(child: Text('Tài liệu học tập')), // Placeholder
      StudentAnnouncementTab(classId: widget.classModel.id),
    ];

    _destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.history_edu_outlined),
        selectedIcon: Icon(Icons.history_edu),
        label: Text('Điểm số'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.folder_outlined),
        selectedIcon: Icon(Icons.folder),
        label: Text('Tài liệu'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.announcement_outlined),
        selectedIcon: Icon(Icons.announcement),
        label: Text('Thông báo'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isCompact(context)) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  // Các hàm _buildMobileLayout và _buildDesktopLayout tương tự như của TA
  // ... (Bạn có thể copy-paste từ class_detail_screen.dart và sửa lại)

  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.classModel.className),
          bottom: TabBar(
            isScrollable: true,
            tabs: _destinations.map((d) => Tab(icon: d.icon, text: (d.label as Text).data!)).toList(),
          ),
        ),
        body: TabBarView(children: _tabs),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classModel.className),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _tabs[_selectedIndex]),
        ],
      ),
    );
  }
}