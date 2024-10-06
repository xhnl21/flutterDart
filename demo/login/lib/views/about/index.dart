// ignore_for_file: file_names, unused_import

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:login/global/notification.dart';
// import 'package:login/componets/btnNavBar/index.dart';
// import 'package:login/views/index.dart';

import 'package:another_flushbar/flushbar.dart';

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
            ElevatedButton(
              onPressed: () {
                // NotificationHelper.pushNotification('title', 'body');
              },
              // onPressed: () => context.push('/NewPageB'),
              child: const Text('notification'),
            ),
            FloatingActionButton(
              onPressed: () async {
                await Flushbar(
                  title: 'Hey Ninja',
                  message:
                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
                  duration: const Duration(seconds: 3),
                ).show(context);
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),          
          ],
        ),
      ),
      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
    );
  }
}