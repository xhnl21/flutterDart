// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class OptionList extends StatelessWidget {
  final List<Map<String, dynamic>> listTile;
  const OptionList(this.listTile, {
    super.key,
  });
  // const OptionList(List<Map<String, dynamic>> listTile, {
  //   super.key,
  // });
  // static const List<Map<String, dynamic>> listTile = [
  //   {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
  //   {'title': 'About', 'icon': Icons.account_box, 'route':'/NewPageA'},
  //   {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/NewPageB'},
  //   {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
  // ];
  @override
  Widget build(BuildContext context) {
    final listTiles = <ListTile>[];
    for (final item in listTile) {
      listTiles.add(
        ListTile(
          leading: Icon(item['icon'] as IconData),
          title: Text(item['title'] as String),
          onTap: () {
            context.go(item['route']);
          },
        ),
      );
    }
    return Column(
      children: listTiles,
    );
  }
}