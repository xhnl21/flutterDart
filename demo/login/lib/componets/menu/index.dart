// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:login/componets/footer/index.dart';
import 'package:login/componets/menu/optionList.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({
    super.key,
    this.listTile,
  });
  static double footerHeight = 40;
  final List<Map<String, dynamic>>? listTile;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red,
              image: DecorationImage(
                image: NetworkImage(
                  "https://www.esports.net/wp-content/uploads/2023/03/dota-2-invoker.jpg",
                ),
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
                        fontSize: 10),
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
                        fontSize: 10),
                  ),
                )
              ],
            ),
          ),
          OptionList(listTile),
          const Expanded(child: SizedBox.shrink()),
          MyFooter(height: footerHeight),
        ],
      ),
    );
  }
}
