import 'package:flutter/material.dart';
import 'package:login/layout/index_state.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage(this.subtitle, this.url, {super.key, required this.bodyWidget, required this.bottomNavigationBar, required this.listTile});
  final List<Widget> bodyWidget;
  final String subtitle;
  final String url;
  final List<Map<String, dynamic>> bottomNavigationBar;
  final List<Map<String, dynamic>> listTile;
  static String title = '';
  List<BottomNavigationBarItem> get methodBNB {
    return <BottomNavigationBarItem>[
      for (final item in bottomNavigationBar)
        BottomNavigationBarItem(
          icon: Icon(item['icon'] as IconData),
          activeIcon: Icon(item['iconActive'] as IconData),
          label: item['label'] as String,
          tooltip: item['label'] as String,
        ),
    ];
  }
  
  @override
  State<MyHomePage> createState() => MyHomePageState();
}