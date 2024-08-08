// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteAbout {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': About.fullPath,
        'name': About.routeName,
        'builder': (context, state) => const About(),
      },
    ];
  }
}