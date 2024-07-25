import 'package:flutter/material.dart';
import 'package:login/views/home/index.dart';
// import 'package:login/componets/btnNavBar/index.dart';


import 'package:login/views/index.dart';
import 'package:login/views/pluss/index.dart';
import 'package:login/views/user/index.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.person_off, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int currentPage = 0;
  final PageController pageController = PageController(initialPage: 0);  
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},    
  ];  
  @override
  Widget build(BuildContext context) {   
    final bottomNavBarItems = <BottomNavigationBarItem>[
      for (final item in bottomNavigationBar)
        BottomNavigationBarItem(
          icon: Icon(item['icon'] as IconData),
          activeIcon: Icon(item['iconActive'] as IconData),
          label: item['label'] as String,
          tooltip: item['label'] as String,
        ),
    ];    
    return Scaffold(
      drawer: const MenuWidget(),
      appBar: AppBar(
        title: const Text('Layout'),
      ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Login(),
          HomeScreen(),
          NewPageA(),
          NewPageB(),
          Pluss(),
          User()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          currentPage = index;
          pageController.animateToPage(index,
              duration: const Duration(microseconds: 300),
              curve: Curves.easeOut);
          setState(() {});
        },        
        backgroundColor: const Color.fromARGB(0xFF, 0x42, 0xA5, 0xF5),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withOpacity(0.5),
        items: bottomNavBarItems
      )
    );
  }
}