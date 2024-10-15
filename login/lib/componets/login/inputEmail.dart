// ignore_for_file: file_names
import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input({
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
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1, vertical: size.width * 0.1),
      child: TextField(
        obscureText: obscureText,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle:
              const TextStyle(color: Color(0xFFBEBCBC), fontWeight: FontWeight.w700),
          icon: const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Icon(Icons.person),
          ),
          //   prefixIcon: Icon(Icons.person, size: 24),
        ),
        onChanged: (value) {},
      ),
    );
  }
}
