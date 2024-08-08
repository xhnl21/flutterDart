// ignore_for_file: avoid_print

import 'package:go_router/go_router.dart';
import 'package:login/router/home/index.dart';
import 'package:login/router/about/index.dart';
import 'package:login/router/products/index.dart';
import 'package:login/router/login/index.dart';
import 'package:login/router/user/index.dart';
import 'package:login/router/pluss/index.dart';
import 'package:login/router/layout/index.dart';
import 'package:login/router/full/index.dart';
class MainGoRouter {
  GoRouter funtGoRouter() {
    final routeLayout = RouteLayout.getLayout();
    final routeHome = RouteHome.getRoutes();
    final routeAbout = RouteAbout.getRoutes();
    final routeProducts = RouteProducts.getRoutes();
    final routeLogin = RouteLogin.getRoutes();
    final routeUser = RouteUser.getRoutes();
    final routePluss = RoutePluss.getRoutes();
    final routeFull = RouteFull.getRoutes();
    List<Map<String, dynamic>> routes = [...routeLayout, ...routeHome, ...routeAbout, ...routeProducts, ...routeLogin, ...routeUser, ...routePluss, ...routeFull];
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