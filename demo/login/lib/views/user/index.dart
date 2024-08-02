import 'package:flutter/material.dart';
// import 'package:login/componets/btnNavBar/index.dart';
// import 'package:login/views/index.dart';

class User extends StatelessWidget {
  const User({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('User'),
      // ),
      body: SafeArea(
        child:
        ListView(
          padding: const EdgeInsets.all(8),
          children: const <Widget>[
              Card(child: _SampleCard(cardName: 'Elevated Card')),
              Card.filled(child: _SampleCard(cardName: 'Filled Card')),
              Card.outlined(child: _SampleCard(cardName: 'Outlined Card')),
          ],
        )
      ),

      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
    );
  }
}
class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.cardName});
  final String cardName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 100,
      child: Center(child: Text(cardName)),
    );
  }
}