// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:login/componets/footer/index.dart';
import 'package:login/componets/menu/optionList.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({
    super.key,
  });
  static double footerHeight = 40;
  static const List<Map<String, dynamic>> listTile = [
    {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
    {'title': 'About', 'icon': Icons.account_box, 'route':'/NewPageA'},
    {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/NewPageB'},
    {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
    {'title': 'Full', 'icon': Icons.abc_rounded, 'route':'/Full'},
  ];  
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
            children: [
                const DrawerHeader(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        image: DecorationImage(
                            image: NetworkImage("https://www.esports.net/wp-content/uploads/2023/03/dota-2-invoker.jpg",),
                            fit: BoxFit.fill,
                        ),
                    ),
                    child: Stack(
                        children: [
                            Positioned(
                                bottom: 20,
                                left: 4.0,
                                child: Text(
                                    "Furion App",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10
                                    ),
                                ),
                            ),
                            Positioned(
                                bottom: 8.0,
                                left: 4.0,
                                child: Text(
                                    "v 1.0.0",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10
                                    ),
                                ),
                            )
                        ],
                    ),
                ),
                const OptionList(listTile),
                const Expanded(child: SizedBox.shrink()),
                MyFooter(height: footerHeight), 
            ],
        ),
    );
  }
}

