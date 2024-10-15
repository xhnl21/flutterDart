// ignore_for_file: file_names
import 'package:flutter/material.dart';

class Password extends StatelessWidget {
  const Password({
    super.key,
    required this.size,
    required this.label,
    required this.hintText,
    required this.obscureText,
  });

  final Size size;
  final String label;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: size.width * .1,
        right: size.width * 0.1,
        bottom: size.height * 0.05,
      ),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: const TextStyle(
              color: Color(0xFFBEBCBC), fontWeight: FontWeight.w700),
          icon: const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Icon(Icons.lock),
          ),
          //   prefixIcon: Icon(Icons.lock_rounded, size: 24),
          suffixIcon: IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: FunctionDemo,
            color: const Color(0xFFBEBCBC),
          ),
        ),
        onChanged: (value) {},
      ),
    );
  }

  // ignore: non_constant_identifier_names
  void FunctionDemo() {
    // ignore: avoid_print
    print('demo');
  }
}
