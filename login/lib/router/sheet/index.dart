// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteSheet {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': Sheet.fullPath,
        'name': Sheet.routeName,
        'builder': (context, state) => const Sheet(),
      },
    ];
  }
}