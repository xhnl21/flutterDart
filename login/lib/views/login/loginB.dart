// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:login/componets/index.dart';
// import 'package:login/views/index.dart';
// import 'package:login/global/connectivity_service.dart';
class LoginB extends StatelessWidget {
  const LoginB({super.key});

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final conn = ConnectivityService.connectionStatusServise();
    //   if (conn[0]['status'] > 0) {
    //       showToast(context, conn[0]['msj']);
    //   }
    // });

    final size = MediaQuery.of(context).size;
    const labelA = "Email";
    const hintTextA = "Enter your email";
    const obscureTextA = false;
    const labelB = "Password";
    const hintTextB = "Enter your password";
    const obscureTextB = true;    
    return Scaffold(
      // drawer: const MenuWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // email
            Input(size: size, label: labelA, hintText: hintTextA, obscureText: obscureTextA),
            // pass
            Password(size: size, label: labelB, hintText: hintTextB, obscureText: obscureTextB),

            ElevatedButton(
              onPressed: () => context.go('/Layout'),
              // onPressed: () => context.push('/Layout'),
              child: const Text('Iniciar Sesion'),
            )
          ],
        ),
      ),
    );
  }
}

// void showToast(BuildContext context, String message) {
//   // print(message);
//   final scaffold = ScaffoldMessenger.of(context);
//   scaffold.showSnackBar(
//     SnackBar(
//       content: Text(message),
//       backgroundColor: Colors.red,
//     ),
//   );
// } 