import 'package:edunote/screens/creator/file_screen.dart';
import 'package:edunote/screens/creator/home_page.dart';
import 'package:flutter/material.dart';

import '../../utils/colour.dart';

class TabViewControl extends StatefulWidget {
  const TabViewControl({super.key});

  @override
  State<TabViewControl> createState() => _TabViewControlState();
}

class _TabViewControlState extends State<TabViewControl>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [HomePage(), FilesScreen()],
      ),
      bottomNavigationBar: Material(
        //we put the tab in bottom here
        color: Colors.white,
        elevation: 8,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colour.purple2,
          labelColor: Colour.purple2,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.folder)),
          ],
        ),
      ),
    );
  }
}

//Tab() shows the name of each tabs. TabBar contain rows of the tabs.
//TabBarView contain the actual widgets of the tabs
//Tab controller Controls which tab is active programmatically.
//You manually create and control the tab switching with TabController.
// You need SingleTickerProviderStateMixin to sync animations (vsync: this).
//WHen u use default tab controller, u set up a controller wothout managing it yourself
