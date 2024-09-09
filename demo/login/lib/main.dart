// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:login/global/connectivity_service.dart';
import 'package:login/global/notification.dart';
// import 'package:login/global/show_toast.dart';
import 'package:login/router/index.dart';
import 'package:connectivity/connectivity.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationHelper.init();
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
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;


  @override
  void initState() {
    super.initState();
    _router = MainGoRouter(); // Inicializar el enrutador
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;

    _connectivityStream.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      // Actualiza la ruta inicial dinámica cuando cambie la conectividad
      ConnectivityService.connectionStatus = result;
      // ShowToast.showToasts(context, _scaffoldMessengerKey);
      final conn = ConnectivityService.connectionStatusServise();
      if (conn[0]['status'] > 0) {
        NotificationHelper.pushNotification('title', conn[0]['msj']);
      }      
      
      String newRoute = MyNavigatorObserver.getCurrentRouteWithParams();
      _router.updateInitialLocation(newRoute);
    });
  }


  @override
  Widget build(BuildContext context) {   
      // ShowToast.showToasts(context); 
    return MaterialApp.router(
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


