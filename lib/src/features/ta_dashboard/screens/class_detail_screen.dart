// lib/src/features/ta_dashboard/screens/class_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../common/utils/responsive_helper.dart'; // Import helper đã tạo
import '../../../data/models/class_model.dart';
import '../widgets/student_list_tab.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;

  const ClassDetailScreen({super.key, required this.classModel});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  // Biến để theo dõi tab/mục đang được chọn cho layout desktop
  int _selectedIndex = 0;

  // Danh sách các tab
  final List<Widget> _tabs = [];
  final List<NavigationRailDestination> _destinations = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo các tab và destination một lần để tránh build lại không cần thiết
    _initializeTabs();
  }

  void _initializeTabs() {
    final classId = widget.classModel.id;

    // Thêm các widget nội dung của từng tab
    _tabs.add(StudentListTab(classId: classId));
    _tabs.add(const Center(child: Text('Nội dung BTVN')));
    _tabs.add(const Center(child: Text('Nội dung Bảng điểm')));

    // Thêm các destination cho NavigationRail
    _destinations.add(const NavigationRailDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: Text('Học sinh'),
    ));
    _destinations.add(const NavigationRailDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment),
      label: Text('BTVN'),
    ));
    _destinations.add(const NavigationRailDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: Text('Bảng điểm'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng helper để kiểm tra kích thước màn hình
    if (ResponsiveHelper.isCompact(context)) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  // Bố cục cho điện thoại (sử dụng TabBar)
  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.classModel.className),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: _destinations[0].icon, text: (_destinations[0].label as Text).data),
              Tab(icon: _destinations[1].icon, text: (_destinations[1].label as Text).data),
              Tab(icon: _destinations[2].icon, text: (_destinations[2].label as Text).data),
            ],
          ),
        ),
        body: TabBarView(children: _tabs),
      ),
    );
  }

  // Bố cục cho máy tính (sử dụng NavigationRail)
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
          Expanded(
            child: _tabs[_selectedIndex],
          ),
        ],
      ),
    );
  }
}