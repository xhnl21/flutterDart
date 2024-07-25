// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RoutePluss {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': '/Pluss',
        'builder': (context, state) => const Pluss(),
      },
    ];
  }
}