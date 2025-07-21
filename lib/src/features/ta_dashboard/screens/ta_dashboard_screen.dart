// lib/src/features/ta_dashboard/screens/ta_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/responsive_helper.dart';
import '../../authentication/providers/auth_providers.dart';
import '../widgets/in_class_view.dart';
import '../widgets/out_class_view.dart';

class TaDashboardScreen extends ConsumerStatefulWidget {
  const TaDashboardScreen({super.key});

  @override
  ConsumerState<TaDashboardScreen> createState() => _TaDashboardScreenState();
}

class _TaDashboardScreenState extends ConsumerState<TaDashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _mainViews = <Widget>[
    InClassView(),
    OutClassView(),
  ];

  @override
  Widget build(BuildContext context) {
    final userModelAsync = ref.watch(userDataProvider(ref.watch(authStateChangesProvider).asData!.value!.uid));
    final isDesktop = !ResponsiveHelper.isCompact(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(userModelAsync.asData?.value?.displayName ?? 'TA Dashboard'),
        // XÓA THUỘC TÍNH `leading`
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          )
        ],
      ),
      // XÓA HOÀN TOÀN `drawer`
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.meeting_room_outlined),
                  selectedIcon: Icon(Icons.meeting_room),
                  label: Text('Trên Lớp'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.class_outlined),
                  selectedIcon: Icon(Icons.class_),
                  label: Text('Ngoài Giờ'),
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _mainViews,
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room_outlined),
            label: 'Trên Lớp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_outlined),
            label: 'Ngoài Giờ',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      )
          : null,
    );
  }
}