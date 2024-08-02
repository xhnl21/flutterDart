import 'package:flutter/material.dart';
import 'package:login/componets/menu/index.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.bodyWidget, required this.bottomNavigationBar, required this.listTile});
  final List<Widget> bodyWidget;
  final List<Map<String, dynamic>> bottomNavigationBar;
  final List<Map<String, dynamic>> listTile;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  String title = '';
  @override
  Widget build(BuildContext context) {
    final bottomNavBarItems = methodBNB;    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),      
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: widget.bodyWidget
      ), 
      bottomNavigationBar: methodActionBNB(bottomNavBarItems),
      drawer: MenuWidget(listTile: widget.listTile),
    );
  }

  List<BottomNavigationBarItem> get methodBNB {
    return <BottomNavigationBarItem>[
    for (final item in widget.bottomNavigationBar)
      BottomNavigationBarItem(
        icon: Icon(item['icon'] as IconData),
        activeIcon: Icon(item['iconActive'] as IconData),
        label: item['label'] as String,
        tooltip: item['label'] as String,
      ),
  ];
  }

  BottomNavigationBar? methodActionBNB(List<BottomNavigationBarItem> bottomNavBarItems) {
    if (widget.bottomNavigationBar.length >= 2) {
      return BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          title = widget.bottomNavigationBar[index]['label'] as String;
          currentPage = index;
          pageController.animateToPage(index,
              duration: const Duration(microseconds: 300),
              curve: Curves.easeOut);
          setState(() {});
        },        
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withOpacity(0.5),
        items: bottomNavBarItems
      );
    } else {
      return null;
    }
  }
}
