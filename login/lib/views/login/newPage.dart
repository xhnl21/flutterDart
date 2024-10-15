// ignore_for_file: file_NewPageA, file_names

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:login/views/index.dart';

class NewPage extends StatefulWidget {
  const NewPage({super.key});
  @override
  State<NewPage> createState() => _NewPageAState();
}

class _NewPageAState extends State<NewPage> {
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
              // onPressed: () => context.push('/NewPageB'),
              onPressed: () => context.go('/NewPageB'),
              child: const Text('New Paga B'),
            ),
          ],
        ),
      ),
    );
  }
}
