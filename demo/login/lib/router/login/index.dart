// ignore_for_file: file_names
import 'package:login/router/inputRouter.dart';

class RouteLogin {
  static List<Map<String, dynamic>> getRoutes() {
    return [
    {
      'path': '/',
      'builder': (context, state) => const LoginB(),
    },
    {
      'path': '/LoginB',
      'builder': (context, state) => const LoginB(),
    },  
    // {
    //   'path': '/Layout',
    //   'builder': (context, state) => const Layout(),
    // },        
    {
      'path': '/HomeScreen',
      'builder': (context, state) => const HomeScreen(),
    },
    {
      'path': '/NewPageA',
      'builder': (context, state) => const NewPageA(),
    },
    {
      'path': '/NewPageB',
      'builder': (context, state) => const NewPageB(),
    },
    ];
  }
}