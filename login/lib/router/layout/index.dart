// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteLayout {
  static List<Map<String, dynamic>> getLayout() {
    return [
      {
        'path': Layout.fullPath,
        'name':Layout.routeName,
        'builder': (context, state) => const Layout(),
      },
    ];
  }
}