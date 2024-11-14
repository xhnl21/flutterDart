// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteHistorySheet {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': HistorySheet.fullPath,
        'name': HistorySheet.routeName,
        'builder': (context, state) => const HistorySheet(),
      },
    ];
  }
}