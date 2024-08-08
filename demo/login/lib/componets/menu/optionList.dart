// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class OptionList extends StatelessWidget {
  final List<Map<String, dynamic>>? listTile;
  const OptionList(this.listTile, {
    super.key,
  });
  // const OptionList(List<Map<String, dynamic>> listTile, {
  //   super.key,
  // });
  static const List<Map<String, dynamic>> listTileOPT = [
    {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
    {'title': 'About', 'icon': Icons.account_box, 'route':'/About'},
    {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/Products'},
    {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
    {'title': 'Full', 'icon': Icons.abc_rounded, 'route':'/Full'},
  ]; 
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>>? listTilesMenu = listTile;

    if (listTile!.isEmpty) {
        listTilesMenu = listTileOPT;
    }
    final listTiles = <ListTile>[];
    for (final item in listTilesMenu!) {
      listTiles.add(
        ListTile(
          leading: Icon(item['icon'] as IconData),
          title: Text(item['title'] as String),
          onTap: () {
            context.go(item['route']);
            // context.push(item['route']);
          },
        ),
      );
    }
    return Column(
      children: listTiles,
    );
  }
}