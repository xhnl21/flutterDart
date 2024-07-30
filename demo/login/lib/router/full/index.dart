// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteFull {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': '/Full',
        'builder': (context, state) => const Full(),
      },
    ];
  }
}