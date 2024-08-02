import 'package:login/layout/index.dart';
import 'package:login/views/full/index.dart';
import 'package:login/views/index.dart';

class Full extends StatelessWidget {
  const Full({super.key});
  static const List<Widget> bodyWidget = [
    HomeScreen(),
    User(),
    Pluss(),
    FullView(),
  ];
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
    {'label': 'FullView', 'icon': Icons.fullscreen, 'iconActive': Icons.fullscreen_sharp, 'route':'/Pluss'},
  ];  
  static const List<Map<String, dynamic>> listTile = [
    {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
    {'title': 'About', 'icon': Icons.account_box, 'route':'/NewPageA'},
    {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/NewPageB'},
    {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
    {'title': 'Full', 'icon': Icons.abc_rounded, 'route':'/Full'},
  ];  
  @override
  Widget build(BuildContext context) {
    return const MyHomePage(
      bodyWidget: bodyWidget,
      bottomNavigationBar: bottomNavigationBar,
      listTile:listTile,
    );
  }
}