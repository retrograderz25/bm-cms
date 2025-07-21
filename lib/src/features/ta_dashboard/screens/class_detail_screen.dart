// lib/src/features/ta_dashboard/screens/class_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../common/utils/responsive_helper.dart';
import '../../../data/models/class_model.dart';
import '../widgets/announcement_list_tab.dart';
import '../widgets/assignment_list_tab.dart';
import '../widgets/class_settings_tab.dart';
import '../widgets/student_list_tab.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;

  const ClassDetailScreen({super.key, required this.classModel});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _tabs;
  late final List<NavigationRailDestination> _destinations;
  late final List<String> _tabLabels;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
  }

  void _initializeTabs() {
    final classId = widget.classModel.id;

    _tabs = [
      StudentListTab(classId: classId),
      // THAY ĐỔI QUAN TRỌNG: Truyền cả object ClassModel
      AssignmentListTab(classModel: widget.classModel),
      const Center(child: Text('Nội dung Bảng điểm')),
      AnnouncementListTab(classId: classId),
      ClassSettingsTab(classModel: widget.classModel),
    ];

    _destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.people_outline),
        selectedIcon: Icon(Icons.people),
        label: Text('Học sinh'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: Text('BTVN'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: Text('Bảng điểm'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.announcement_outlined),
        selectedIcon: Icon(Icons.announcement),
        label: Text('Thông báo'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Cài đặt'),
      ),
    ];

    _tabLabels = _destinations.map((d) => (d.label as Text).data!).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isCompact(context)) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.classModel.className),
          bottom: TabBar(
            isScrollable: true,
            tabs: List.generate(_tabs.length, (index) {
              return Tab(
                icon: _destinations[index].icon,
                text: _tabLabels[index],
              );
            }),
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
          Expanded(
            child: _tabs[_selectedIndex],
          ),
        ],
      ),
    );
  }
}