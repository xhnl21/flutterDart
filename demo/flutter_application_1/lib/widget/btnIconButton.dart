// ignore_for_file: file_names
import 'package:flutter/material.dart';

class FunctBtn extends StatelessWidget {
  const FunctBtn({super.key});
  static const tooltipC = 'JAJAJAJ Show Snackbar';
  static const List<Map<String, dynamic>> iconButton = [
    {'tooltip': tooltipC, 'icon': Icons.umbrella},
    {'tooltip': 'Go to the next page', 'icon': Icons.add_alert},
    {'tooltip': tooltipC, 'icon': Icons.plus_one},
  ];
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

List<Widget> btnIconButtonFunction() {
  final iconButtons = <Widget>[];
  for (final item in FunctBtn.iconButton) {
    iconButtons.add(
      IconButton(
        icon: Icon(item['icon'] as IconData),
        tooltip: item['tooltip'] as String,
        onPressed: () {
          // Add your button press logic here
        },
      ),
    );
  }
  // ignore: avoid_print
  // print(iconButtons[0]);
  return iconButtons;
}
