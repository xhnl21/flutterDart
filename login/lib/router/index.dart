// ignore_for_file: avoid_print
// import 'package:connectivity/connectivity.dart';
import 'package:go_router/go_router.dart';
import 'package:login/router/home/index.dart';
import 'package:login/router/about/index.dart';
import 'package:login/router/badger/index.dart';
import 'package:login/router/sheet/index.dart';
import 'package:login/router/products/index.dart';
import 'package:login/router/login/index.dart';
import 'package:login/router/user/index.dart';
import 'package:login/router/pluss/index.dart';
import 'package:login/router/layout/index.dart';
import 'package:login/router/full/index.dart';
import 'package:login/views/index.dart';
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
class MainGoRouter {
  String _initialLocation = '/';

  MainGoRouter() {
    _determineInitialLocation(); // Determina la ubicación inicial de forma dinámica
  }

  void _determineInitialLocation() {
    _initialLocation = MyNavigatorObserver.getCurrentRouteWithParams();
  }

  void updateInitialLocation(String newLocation) {
    _initialLocation = newLocation;
  }


  GoRouter funtGoRouter() {
    if (_initialLocation == '//' || _initialLocation == '//LoginB') {
      _initialLocation = '/';
      // _initialLocation = '/LoginB';
    }  
    // print(32);
    // print(_initialLocation);
    // print(34);
    final routeLayout = RouteLayout.getLayout();
    final routeHome = RouteHome.getRoutes();
    final routeAbout = RouteAbout.getRoutes();
    final routeBadger = RouteBadger.getRoutes();
    final routeSheet = RouteSheet.getRoutes();
    final routeProducts = RouteProducts.getRoutes();
    final routeLogin = RouteLogin.getRoutes();
    final routeUser = RouteUser.getRoutes();
    final routePluss = RoutePluss.getRoutes();
    final routeFull = RouteFull.getRoutes();
    List<Map<String, dynamic>> routes = [
        ...routeLayout, ...routeHome, ...routeAbout, 
        ...routeProducts, ...routeLogin, ...routeUser, 
        ...routePluss, ...routeFull, ...routeBadger,
        ...routeSheet,
    ];
    final GoRouter appRouterFurion = GoRouter(
        // debugLogDiagnostics: false,
        navigatorKey: navigatorKey,
        // initialLocation: '/',
        initialLocation: _initialLocation, // Usa la ubicación inicial dinámica
        routes: <GoRoute>[
          for (final route in routes)
            GoRoute(
              parentNavigatorKey: navigatorKey,
              name: route['name'],
              path: route['path'] as String,
              builder: route['builder'],
            ),
        ],
        observers: [ // Add your navigator observers
          MyNavigatorObserver(),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(child: Text('Página no encontrada: ${state.uri.toString()}')),
        ),
      );
      return appRouterFurion;
  }
}

class MyNavigatorObserver extends RouteObserver<PageRoute<dynamic>> {
  static String currentRoute = '/'; // Variable estática para almacenar la ruta actual
  static Map<String, String>? currentParameters; // Variable estática para almacenar los parámetros actuales
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    // print('Route pushed: ${route.settings.name}');
    currentRoute = route.settings.name ?? '/';

    if (route.settings.arguments != null && route.settings.arguments is Map<String, String>) {
      currentParameters = route.settings.arguments as Map<String, String>;
      // print('Route parameters: $currentParameters');
    }
  }
  
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    print('Route popped: ${route.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    print('Route removed: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    print('Route replaced: ${newRoute?.settings.name}');
  }

  static String getCurrentRouteWithParams() {
    String result = currentRoute;
    if (currentParameters != null && currentParameters!.isNotEmpty) {
        currentParameters!.forEach((key, value) {
          result = '/$result/$value';
        });  
        return result;   
    }
    return '/$currentRoute';
  }
}