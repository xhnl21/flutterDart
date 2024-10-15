// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
// import 'package:login/global/show_toast.dart';
import 'package:login/layout/index.dart';
import 'package:login/views/home/details.dart';
import 'package:login/views/index.dart';

class HomeDetails extends StatelessWidget {
  final String subtitle = 'Home Detail';
  final int id;
  const HomeDetails(this.id, {super.key});
  static const routeName = 'HomeDetails';
  static const fullPath = '/$routeName/:id';

  static const List<Map<String, dynamic>> bottomNavigationBar = [
    // {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    // {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    // {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
    // {'label': 'FullView', 'icon': Icons.fullscreen, 'iconActive': Icons.fullscreen_sharp, 'route':'/Pluss'},
  ];  
  static const List<Map<String, dynamic>> listTile = [
    // {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
    // {'title': 'About', 'icon': Icons.account_box, 'route':'/About'},
    // {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/Products'},
    // {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
    // {'title': 'Full', 'icon': Icons.abc_rounded, 'route':'/Full'},
  ];

  static const String url = '/Full';

  Future<List<Map<String, dynamic>>> inits() async {
      String url = 'https://pokeapi.co/api/v2/pokemon/$id/';
      final List<Map<String, dynamic>> masterDetails = [];
      final res = await Dio().get(url);
      if (res.data.isNotEmpty) {
        masterDetails.add(res.data);
        return masterDetails;
      } else {
        return [];
      }
  }    
  @override
  Widget build(BuildContext context) { 
    // ShowToast.showToasts(context);   
    return MyHomePage(
      bodyWidget: [
      HomeDetailsView(inits: inits)],
      bottomNavigationBar: bottomNavigationBar,
      listTile:listTile,
      subtitle,
      url,
    );
  }
}

