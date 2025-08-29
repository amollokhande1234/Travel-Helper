import 'package:flutter/material.dart';
import 'package:travelhelper/Group/GroupPage.dart';
import 'package:travelhelper/UI/Pages/GoogleMapPage.dart';
import 'package:travelhelper/UI/Pages/MapPage.dart';
import 'package:travelhelper/UI/Pages/ProfilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [GroupPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Travel Helper',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: _bottomNavBar(),
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _navigateBottomBar,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_3_rounded),
          label: "Groups",
        ),
        // BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Map"),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2_rounded),
          label: "Profile",
        ),
      ],
    );
  }
}
