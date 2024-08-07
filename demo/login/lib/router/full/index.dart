// ignore_for_file: file_names, avoid_print
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:login/router/inputRouter.dart';

class RouteFull {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': '/Full',
        'builder': (context, state) => const Full(),
      },
      {
        'path': '/FullDetail/:id',
        'builder': (BuildContext context, GoRouterState state) {
          final ids = state.pathParameters["id"]!;
          int id = int.parse(ids);
          return FullDetails(id);
        },
      },      
    ];
  }
}