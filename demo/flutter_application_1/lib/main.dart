import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screens.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  final title = 'hola mundo';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: const HomeScreens(),
    );
  }
}
