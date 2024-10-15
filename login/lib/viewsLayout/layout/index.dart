import 'package:flutter/material.dart';
import 'package:login/viewsLayout/index.dart';

import '../../layout/index.dart';
import '../../views/full/index.dart';
// dynamic [appBar.title, body.children, bottomNavigationBar]

class Layout extends StatelessWidget {
  const Layout({super.key});
  static const routeName = 'Layout';
  static const fullPath = '/$routeName';

  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},  
    // {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},    
  ];
  static const List<Map<String, dynamic>> contentCard = [
    {'title': 'Homes', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'subtitle':'Este es el subtitulo del card. Aqui podemos colocar descripción de este card.'},
    {'title': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'subtitle':'Este es el subtitulo del card. Aqui podemos colocar descripción de este card.'},
    {'title': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'subtitle':'Este es el subtitulo del card. Aqui podemos colocar descripción de este card.'},  
    {'title': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'subtitle':'Este es el subtitulo del card. Aqui podemos colocar descripción de este card.'},    
  ];  

  static const List<Widget> bodyWidget = [
    HomeScreen(),
    User(contentCard),
    Pluss(),
    FullView(),
  ];

  static const List<Map<String, dynamic>> listTile = [
    // {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
    // {'title': 'About', 'icon': Icons.account_box, 'route':'/About'},
    // {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/Products'},
    // {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
    // {'title': 'Full', 'icon': Icons.abc_rounded, 'route':'/Full'},
  ];  
  static const String subtitle = 'Detail FullView';  
  static const  String url = '';   
  @override
  Widget build(BuildContext context) {
    return const MyHomePage(
      bodyWidget: bodyWidget,
      bottomNavigationBar: bottomNavigationBar,
      listTile:listTile,
      subtitle,
      url,  
    );
  }
}