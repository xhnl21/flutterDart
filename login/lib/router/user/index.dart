// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteUser {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': User.fullPath,
        'name':User.routeName,
        'builder': (context, state) => const User([]),
      },
    ];
  }
}