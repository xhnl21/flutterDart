// ignore_for_file: file_names

import 'package:flutter/material.dart';
// import 'package:login/views/index.dart';

class Name extends StatelessWidget {
  const Name({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // drawer: const MenuWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // email
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.1, vertical: size.width * 0.1),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  labelStyle: TextStyle(
                      color: Color(0xFFBEBCBC), fontWeight: FontWeight.w700),
                  icon: Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Icon(Icons.person),
                  ),
                  //   prefixIcon: Icon(Icons.person, size: 24),
                ),
                onChanged: (value) {},
              ),
            ),
            // pass
            Padding(
              padding: EdgeInsets.only(
                left: size.width * .1,
                right: size.width * 0.1,
                bottom: size.height * 0.05,
              ),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  labelStyle: TextStyle(
                      color: Color(0xFFBEBCBC), fontWeight: FontWeight.w700),
                  icon: Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Icon(Icons.lock),
                  ),
                  //   prefixIcon: Icon(Icons.lock_rounded, size: 24),
                ),
                onChanged: (value) {},
              ),
            ),
            ElevatedButton(
              onPressed: () => {},
              child: const Text('Iniciar Sesion'),
            )
          ],
        ),
      ),
    );
  }
}
