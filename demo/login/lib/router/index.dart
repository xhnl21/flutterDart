// ignore_for_file: avoid_print

import 'package:go_router/go_router.dart';
import 'package:login/router/home/index.dart';
import 'package:login/router/login/index.dart';
import 'package:login/router/user/index.dart';
import 'package:login/router/pluss/index.dart';
class MainGoRouter {
  GoRouter funtGoRouter() {
    final routeHome = RouteHome.getRoutes();
    final routeLogin = RouteLogin.getRoutes();
    final routeUser = RouteUser.getRoutes();
    final routePluss = RoutePluss.getRoutes();
    List<Map<String, dynamic>> routes = [...routeHome, ...routeLogin, ...routeUser, ...routePluss];
    final GoRouter appRouterFurion = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          for (final route in routes)
            GoRoute(
              path: route['path'] as String,
              builder: route['builder'],
            ),
        ],
      );
      return appRouterFurion;
  }
}