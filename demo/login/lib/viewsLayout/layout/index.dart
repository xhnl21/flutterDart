import 'package:flutter/material.dart';
import 'package:login/viewsLayout/index.dart';

import '../../layout/index.dart';
import '../../views/full/index.dart';
// dynamic [appBar.title, body.children, bottomNavigationBar]

class Layout extends StatelessWidget {
  const Layout({super.key});

  
  static const List<Widget> bodyWidget = [
    HomeScreen(),
    User(),
    Pluss(),
    FullView(),
  ];
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},  
    // {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},    
  ];
  static const List<Map<String, dynamic>> listTile = [
    {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
    {'title': 'About', 'icon': Icons.account_box, 'route':'/NewPageA'},
    {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/NewPageB'},
    {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
    {'title': 'Full', 'icon': Icons.abc_rounded, 'route':'/Full'},
  ];    
  @override
  Widget build(BuildContext context) {
    return const MyHomePage(
      bodyWidget: bodyWidget,
      bottomNavigationBar: bottomNavigationBar,
      listTile:listTile,
    );
  }
}