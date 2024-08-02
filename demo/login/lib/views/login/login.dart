// ignore_for_file: file_Logins

// import 'package:flutter/material.dart';
import 'package:login/views/index.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('Home Page'),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: ElevatedButton(
              onPressed: () {
                MaterialPageRoute route =
                    MaterialPageRoute(builder: (context) => const NewPageA());
                Navigator.push(context, route);
              },
              child: const Text('Ir a otra pagina A'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                MaterialPageRoute route =
                    MaterialPageRoute(builder: (context) => const NewPageB());
                Navigator.push(context, route);
              },
              child: const Text('Ir a otra pagina B'),
            ),
          ),
        ],
      ),
    );
  }
}
