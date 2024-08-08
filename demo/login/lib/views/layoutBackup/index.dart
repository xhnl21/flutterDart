import 'package:flutter/material.dart';
import 'package:login/componets/menu/index.dart';
import 'package:login/views/home/index.dart';
import 'package:login/views/login/login.dart';
import 'package:login/views/login/newPageA.dart';
import 'package:login/views/login/newPageB.dart';
import 'package:login/views/pluss/index.dart';
import 'package:login/views/user/index.dart';
// dynamic [appBar.title, body.children, bottomNavigationBar]

class Layout extends StatefulWidget {
  const Layout({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},  
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},    
  ];
  static const List<Widget> bodyWidget = [
    Login(),
    HomeScreen(),
    NewPageA(),
    NewPageB(),
    Pluss(),
    User([])
  ];
  static const List<Map<String, dynamic>> listTile = [
    // {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
    // {'title': 'About', 'icon': Icons.account_box, 'route':'/NewPageA'},
    // {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/NewPageB'},
    // {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
    // {'title': 'Full', 'icon': Icons.abc_rounded, 'route':'/Full'},
  ];   
  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int currentPage = 0;
  String title = 'ZZHome';
  List<Map<String, dynamic>> bottomNavigationBar = Layout.bottomNavigationBar;
  List<Widget> bodyWidget = Layout.bodyWidget;
  final PageController pageController = PageController(initialPage: 0);  
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
      drawer: const MenuWidget(listTile:Layout.listTile),
      appBar: AppBar(
        title: Text('ZZ$title'),
      ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: bodyWidget,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          title = bottomNavigationBar[index]['label'] as String;
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