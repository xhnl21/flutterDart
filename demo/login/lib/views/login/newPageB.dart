// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:login/views/index.dart';

class NewPageB extends StatefulWidget {
  const NewPageB({super.key});
  @override
  State<NewPageB> createState() => _NewPageBState();
}

class _NewPageBState extends State<NewPageB> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('New Paga B'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/NewPageA'),
              // onPressed: () => context.push('/NewPageA'),
              child: const Text('New Paga A'),
            ),
          ],
        ),
      ),
    );
  }
}
