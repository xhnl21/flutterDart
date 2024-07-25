// ignore_for_file: file_NewPageA, file_names

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:login/views/index.dart';

class NewPageA extends StatefulWidget {
  const NewPageA({super.key});
  @override
  State<NewPageA> createState() => _NewPageAState();
}

class _NewPageAState extends State<NewPageA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('New Paga A'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/NewPageB'),
              child: const Text('New Paga B'),
            ),
          ],
        ),
      ),
    );
  }
}
