import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class MyFooter extends StatelessWidget {
    final double height;
    const MyFooter({super.key, required this.height});
    @override
    Widget build(BuildContext context) {
      return ListTile(
          leading: const Icon(Icons.logout_outlined),
          title: const Text('Logout'),
          onTap: () { 
            context.go('/LoginB');
          },
      );
    }
}
