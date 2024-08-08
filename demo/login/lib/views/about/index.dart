// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:login/componets/btnNavBar/index.dart';
// import 'package:login/views/index.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.person_off, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('Home'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/NewPageA'),
              // onPressed: () => context.push('/NewPageA'),
              child: const Text('NewPageA'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/NewPageB'),
              // onPressed: () => context.push('/NewPageB'),
              child: const Text('NewPageB'),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
    );
  }
}