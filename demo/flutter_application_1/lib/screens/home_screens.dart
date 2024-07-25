import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/btnIconButton.dart';
import 'package:flutter_application_1/widget/screen.dart';

// ctrl + .
class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});
  static const colorA = Color.fromARGB(0xFF, 0x42, 0xA5, 0xF5);
  static const black = Colors.black;
  static const red = Colors.red;
  static const white = Colors.white;
  static const colorB = Color.fromARGB(255, 252, 247, 0);
  static const colorE = Color.fromARGB(0xFF, 0x42, 0xA5, 0xF5);
  static const styleB = TextStyle(fontSize: 14, color: colorB);
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    // {'label': 'Umbrella', 'icon': Icons.umbrella},
    // {'label': 'Add Alert', 'icon': Icons.add_alert},
    // {'label': 'Pluss', 'icon': Icons.plus_one},
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},    
    
  ];
  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  int currentPage = 0;
  final PageController pageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    final textB = Text('Hello AppBar! $currentPage', style: HomeScreens.styleB);
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: functScaffold(textB));
  }

  Scaffold functScaffold(Text textB) {
    return Scaffold(
        appBar: AppBar(
          title: textB,
          backgroundColor: HomeScreens.colorE,
          actions: btnIconButtonFunction(),
        ),
        body: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            CustomScreen(color: HomeScreens.black),
            CustomScreen(color: HomeScreens.red),
            CustomScreen(color: HomeScreens.white),
          ],
        ),
        bottomNavigationBar: btnBarFunction(HomeScreens.bottomNavigationBar));
  }

  // BottomNavigationBar dinamico, recive una lista de iconos y label
  BottomNavigationBar btnBarFunction(
      List<Map<String, dynamic>> bottomNavigationBar) {
    final bottomNavBarItems = <BottomNavigationBarItem>[
      for (final item in bottomNavigationBar)
        BottomNavigationBarItem(
          icon: Icon(item['icon'] as IconData),
          label: item['label'] as String,
        ),
    ];
    return BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          currentPage = index;
          pageController.animateToPage(index,
              duration: const Duration(microseconds: 300),
              curve: Curves.easeOut);
          setState(() {});
        },
        backgroundColor: HomeScreens.colorE,
        selectedItemColor: HomeScreens.black,
        unselectedItemColor: HomeScreens.black.withOpacity(0.5),
        items: bottomNavBarItems);
  }
}
