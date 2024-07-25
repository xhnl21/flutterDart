// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteHome {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': '/Home',
        'builder': (context, state) => const HomeScreen(),
      },
    ];
  }
}