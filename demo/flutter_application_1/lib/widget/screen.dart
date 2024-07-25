import 'package:flutter/material.dart';

class CustomScreen extends StatelessWidget {
  final Color color;
  const CustomScreen({super.key, required this.color});
  static const colorE = Color.fromARGB(0xFF, 0x42, 0xA5, 0xF5);
  static const colorD = Color.fromARGB(255, 53, 160, 53);
  static const styleD = TextStyle(fontSize: 14, color: colorD);

  @override
  Widget build(BuildContext context) {
    final listView =
        ListView(children: List.generate(100, (i) => cicloText(i, styleD)));
    final safeArea = SafeArea(bottom: false, left: false, child: listView);
    return Container(
      color: color,
      child: Center(
        child: safeArea,
      ),
    );
  }
}

Center cicloText(int i, dynamic style) {
  final textA = Text('$i - Hello body!', style: style);
  final center = Center(child: textA);
  return center;
}
