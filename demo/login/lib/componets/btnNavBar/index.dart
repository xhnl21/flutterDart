// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class BtnNavBar extends StatelessWidget {
  final List<Map<String, dynamic>> bottomNavigationBar;
  const BtnNavBar(this.bottomNavigationBar, {super.key});

  @override
  Widget build(BuildContext context) {   
    final bottomNavBarItems = <BottomNavigationBarItem>[
      for (final item in bottomNavigationBar)
        BottomNavigationBarItem(
          icon: Icon(item['icon'] as IconData),
          activeIcon: Icon(item['iconActive'] as IconData), 
          label: item['label'] as String,
          // backgroundColor: Colors.black      
        ),
    ];
    return BottomNavigationBar(
        onTap: (index) {
            context.go(bottomNavigationBar[index]['route'] as String);
        },
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.black,
        // unselectedItemColor: Colors.black.withOpacity(0.5),
        items: bottomNavBarItems
    );
  }
}
