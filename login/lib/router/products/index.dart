// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteProducts {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': Products.fullPath,
        'name':Products.routeName,
        'builder': (context, state) => const Products(),
      },
    ];
  }
}