import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class BackBottom extends StatelessWidget {
  final String url;
  const BackBottom(this.url, {super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        context.go(url);
        // context.push(url);
      }
    );
  }
}