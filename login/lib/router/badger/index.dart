// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteBadger {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': Badger.fullPath,
        'name': Badger.routeName,
        'builder': (context, state) => const Badger(),
      },
    ];
  }
}