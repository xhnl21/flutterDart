// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteCreateSheet {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': CreateSheet.fullPath,
        'name': CreateSheet.routeName,
        'builder': (context, state) => const CreateSheet(),
      },
    ];
  }
}