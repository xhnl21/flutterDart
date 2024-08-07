// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
// import 'package:login/componets/btnNavBar/index.dart';
// import 'package:login/views/index.dart';

class User extends StatelessWidget {
  final List<Map<String, dynamic>> bottomNavigationBar;
  const User(this.bottomNavigationBar, {super.key});
  // static const List<Map<String, dynamic>> bottomNavigationBar;
  // = [
  //   {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
  //   {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
  //   {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  // ];

  @override
  Widget build(BuildContext context) {

    // print(bottomNavigationBar);
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('User'),
      // ),
      body: SafeArea(
        child:
        ListView.builder(
          itemCount: bottomNavigationBar.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final card = bottomNavigationBar[index];
            return Card(
                margin: const EdgeInsets.all(15),
                elevation: 10,
                child: CardWidgetCustom(card: card),
              );
          },
        )
      ),

      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
    );
  }
}

class CardWidgetCustom extends StatelessWidget {
  const CardWidgetCustom({
    super.key,
    required this.card,
  });
  final Map<String, dynamic> card;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          // contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
          leading: Icon(card['icon']),
          title: Text(card['title']),
          subtitle: Text(card['subtitle']),
          trailing: Icon(card['iconActive']),
        ),
      ],
    );
  }
}