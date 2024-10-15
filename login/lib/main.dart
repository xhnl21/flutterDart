// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:login/global/connectivity_service.dart';
// import 'package:login/global/notification.dart';
import 'package:login/router/index.dart';
import 'package:url_strategy/url_strategy.dart';

import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // NotificationHelper.init();
  setPathUrlStrategy();
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({ super.key });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MainGoRouter _router; // Declarar el enrutador aquí para acceso posterior
  // Create a GlobalKey for the ScaffoldMessenger
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _router = MainGoRouter(); // Inicializar el enrutador

    initConnectivity();
    _connectivitySubscription =
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

    // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
      // print(_connectionStatus);
      final conn = ConnectivityService.connectionStatusServises(_connectionStatus[0].toString());
      _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(conn[0]['msj']),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
      );
      String newRoute = MyNavigatorObserver.getCurrentRouteWithParams();
      _router.updateInitialLocation(newRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: _scaffoldMessengerKey, // Assign the GlobalKey here
      debugShowCheckedModeBanner: false,
      title: 'Furion App',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: Colors.black, // Your primary color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black, // Your seed color
          primary: Colors.blue, // bottom color
          secondary: Colors.black, // Your secondary color
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // appBar color
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.blue, 
          type: BottomNavigationBarType.fixed
        ),
        dialogTheme: const DialogTheme(
          // backgroundColor:Colors.black,
          // elevation: 6,
          // shadowColor: Colors.black,
          // barrierColor:Colors.red,
          // surfaceTintColor:Colors.red,
        ),
      ),
      // routerConfig: MainGoRouter().funtGoRouter(),   
      routerConfig: _router.funtGoRouter(),
    );
  }
}