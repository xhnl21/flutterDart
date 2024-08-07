// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:login/componets/menu/index.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage(this.subtitle, this.url, this.pageCountController, {super.key, required this.bodyWidget, required this.bottomNavigationBar, required this.listTile});
  final List<Widget> bodyWidget;
  final String subtitle;
  final String url;
  final int pageCountController;
  final List<Map<String, dynamic>> bottomNavigationBar;
  final List<Map<String, dynamic>> listTile;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {  
  final PageController pageController = PageController(initialPage: 3);
  int currentPage = 0;
  String title = '';
  @override
  Widget build(BuildContext context) {
    final bottomNavBarItems = methodBNB;
    var appBar = AppBar(
        actions: [
          NewWidget(widget.url),
        ],
        title: Text(widget.subtitle),
    );
    if (widget.url.isEmpty) {
        appBar = AppBar(
            title: Text(title),
        );
    }
    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: widget.bodyWidget
        ),
        bottomNavigationBar: methodActionBNB(bottomNavBarItems),
        drawer: MenuWidget(listTile: widget.listTile),
      )
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

class NewWidget extends StatelessWidget {
  final String url;
  const NewWidget(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        context.go(url);
      }
    );
  }
}
