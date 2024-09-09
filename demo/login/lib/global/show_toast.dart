// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:login/global/connectivity_service.dart';

class ShowToast {
  // final dynamic context;
  // ShowToast({
  //     this.context,
  // });
  // static void showToasts(context) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final conn = ConnectivityService.connectionStatusServise();
  //     if (conn[0]['status'] > 0) {
  //       final scaffold = ScaffoldMessenger.of(context);
  //       scaffold.showSnackBar(
  //         SnackBar(
  //           content: Text(conn[0]['msj']),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   });  
  // }
  // static void showToasts(BuildContext context, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
  static void showToasts(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final conn = ConnectivityService.connectionStatusServise();
      print(conn);
      if (conn[0]['status'] > 0) {
        final scaffold = ScaffoldMessenger.of(context);      
          scaffold.showSnackBar(
            SnackBar(
              content: Text(conn[0]['msj']),
              backgroundColor: Colors.red,
            ),
          );
      } else {
        print('ScaffoldMessenger is not available');
      }
    });
  }  
}