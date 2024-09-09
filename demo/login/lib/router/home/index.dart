// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:login/router/inputRouter.dart';


class RouteHome {
  static List<Map<String, dynamic>> getRoutes() {
    return [
      {
        'path': Home.fullPath,
        'name': Home.routeName,
        'builder': (context, state) => const Home(),
      },
      {
        'path': HomeDetails.fullPath,
        'name': HomeDetails.routeName,
        'builder': (BuildContext context, GoRouterState state) {
          final ids = state.pathParameters["id"]!;
          int id = int.parse(ids);
          return HomeDetails(id);
        },
      },      
    ];
  }
}