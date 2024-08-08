import 'package:flutter/material.dart';
// import 'package:login/componets/btnNavBar/index.dart';
// import 'package:login/views/index.dart';

class Pluss extends StatelessWidget {
  const Pluss({super.key});
  static const routeName = 'Pluss';
  static const fullPath = '/$routeName';  
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    // {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_2_sharp, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  @override
  Widget build(BuildContext context) {   
    return const Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('Pluss'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pluss')
          ],
        ),
      ),
      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
    );
  }
}