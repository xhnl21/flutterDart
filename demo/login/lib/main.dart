// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:login/router/index.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Furion App',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: Colors.black, // Your primary color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black, // Your seed color
          primary: Colors.blue, // bottom color
          secondary: Colors.black, // Your secondary color
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // appBar color
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.blue, 
          type: BottomNavigationBarType.fixed
        )
      ),
      routerConfig: MainGoRouter().funtGoRouter()      
    );
  }
}
