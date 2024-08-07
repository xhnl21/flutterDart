// ignore_for_file: avoid_print

import 'package:login/layout/index.dart';
import 'package:login/views/full/details.dart';
import 'package:login/views/index.dart';

class FullDetails extends StatelessWidget {
  final int id;
  FullDetails(this.id, {super.key});

  final List<Map<String, dynamic>> _data = [
    {'id':1, 'user_id': 1, 'order':1, 'name': 'John Doe 1', 'age': 30, 'email': 'john.doe@example.com'},  
    {'id':2, 'user_id': 1, 'order':2, 'name': 'Jane Smith 1', 'age': 25, 'email': 'jane.smith@example.com'},
    {'id':3, 'user_id': 1, 'order':3, 'name': 'Bob Johnson 1', 'age': 40, 'email': 'bob.johnson@example.com'},
    {'id':4, 'user_id': 1, 'order':4, 'name': 'Sarah Lee 1', 'age': 35, 'email': 'sarah.lee@example.com'},

    {'id':5, 'user_id': 2, 'order':5, 'name': 'John Doe 2', 'age': 30, 'email': 'john.doe@example.com'},  
    {'id':6, 'user_id': 2, 'order':6, 'name': 'Jane Smith 2', 'age': 25, 'email': 'jane.smith@example.com'},
    {'id':7, 'user_id': 2, 'order':7, 'name': 'Bob Johnson 2', 'age': 40, 'email': 'bob.johnson@example.com'},
    {'id':8, 'user_id': 2, 'order':8, 'name': 'Sarah Lee 2', 'age': 35, 'email': 'sarah.lee@example.com'},   

    {'id':9, 'user_id': 3, 'order':9, 'name': 'John Doe 3', 'age': 30, 'email': 'john.doe@example.com'},  
    {'id':10, 'user_id': 3, 'order':10, 'name': 'Jane Smith 3', 'age': 25, 'email': 'jane.smith@example.com'},
    {'id':11, 'user_id': 3, 'order':11, 'name': 'Bob Johnson 3', 'age': 40, 'email': 'bob.johnson@example.com'},
    {'id':12, 'user_id': 3, 'order':12, 'name': 'Sarah Lee 3', 'age': 35, 'email': 'sarah.lee@example.com'},
    
    {'id':13, 'user_id': 4, 'order':13, 'name': 'John Doe 4', 'age': 30, 'email': 'john.doe@example.com'},  
    {'id':14, 'user_id': 4, 'order':14, 'name': 'Jane Smith 4', 'age': 25, 'email': 'jane.smith@example.com'},
    {'id':15, 'user_id': 4, 'order':15, 'name': 'Bob Johnson 4', 'age': 40, 'email': 'bob.johnson@example.com'},
    {'id':16, 'user_id': 4, 'order':16, 'name': 'Sarah Lee 4', 'age': 35, 'email': 'sarah.lee@example.com'},    
  ];
  
  List<Map<String, dynamic>> filterData() {
      return _data.where((item) => item['user_id'] == id).toList();
  }

  static const List<Map<String, dynamic>> bottomNavigationBar = [
    // {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    // {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    // {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
    // {'label': 'FullView', 'icon': Icons.fullscreen, 'iconActive': Icons.fullscreen_sharp, 'route':'/Pluss'},
  ];  
  static const List<Map<String, dynamic>> listTile = [
    {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
    {'title': 'About', 'icon': Icons.account_box, 'route':'/NewPageA'},
    {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/NewPageB'},
    {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
    {'title': 'Full', 'icon': Icons.abc_rounded, 'route':'/Full'},
  ];
  final String subtitle = 'Detail FullView';
  static const String url = '/Full';
  final int pageCountController = 3;
  @override
  Widget build(BuildContext context) {  
    List<Map<String, dynamic>> result = filterData(); 
    List<Widget> bodyWidget = [
      FullDetailsView(result),
    ];
    return MyHomePage(
      bodyWidget: bodyWidget,
      bottomNavigationBar: bottomNavigationBar,
      listTile:listTile,
      subtitle,
      url,
      pageCountController
    );
  }
}