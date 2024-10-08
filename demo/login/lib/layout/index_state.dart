// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:login/componets/btn/backbottom.dart';
import 'package:login/componets/menu/index.dart';
import 'package:login/layout/index.dart';

class MyHomePageState extends State<MyHomePage> {
  int currentPage = 0;
  PageController pageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {  
    String text = MyHomePage.title;
    if (text.isEmpty) {
        text = widget.subtitle;
    }
    final bottomNavBarItems = widget.methodBNB;
    var appBar = AppBar(
        actions: [
            BackBottom(widget.url),
        ],
        title: Text(text),
    );
    if (widget.url.isEmpty) {
        appBar = AppBar(
            title: Text(text),
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

  BottomNavigationBar? methodActionBNB(List<BottomNavigationBarItem> bottomNavBarItems) {
    if (widget.bottomNavigationBar.length >= 2) {
      return BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          MyHomePage.title = widget.bottomNavigationBar[index]['label'] as String;
          currentPage = index;      
          pageController.animateToPage(
              index,
              duration: const Duration(microseconds: 300),
              curve: Curves.easeOut
          );
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