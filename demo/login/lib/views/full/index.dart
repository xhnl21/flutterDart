import 'package:flutter/material.dart';
// import 'package:login/componets/btnNavBar/index.dart';
// import 'package:login/views/index.dart';

class FullView extends StatelessWidget {
  const FullView({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  @override
  Widget build(BuildContext context) {   
    return const Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('User'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Full')
          ],
        ),
      ),
      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
    );
  }
}