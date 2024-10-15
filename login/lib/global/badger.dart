// import 'dart:io';
// import 'package:flutter/foundation.dart';
// ignore_for_file: avoid_print

import 'package:flutter/services.dart';

class BadgeManager  {
  static const MethodChannel _channel = MethodChannel('com.example/badge');

  static Future<void> updateBadge(int count) async {
    try {
      await _channel.invokeMethod('updateBadge', {'count': count});
    } on PlatformException catch (e) {
      print("Error updating badge: '${e.message}'.");
    }
  }
  // static const MethodChannel _channel = MethodChannel('com.example/platformInfo');
  // static Future<String> getPlatform() async {
  //   final String platform = await _channel.invokeMethod('getPlatform');
  //   return platform;
  // }

  // static void updateBadgeCount(int count) {
  //   _channel.invokeMethod('updateBadgeCount', {"count": count});
  // }

  // static void removeBadge() {
  //   _channel.invokeMethod('removeBadge');
  // }

  // static Future<bool> isAppBadgeSupported() async {
  //   bool? appBadgeSupported =
  //       await _channel.invokeMethod('isAppBadgeSupported');
  //   return appBadgeSupported ?? false;
  // }
  // static void updateBadge(int count) {
  //   if (count > 0) {
  //     if (Platform.isAndroid || Platform.isIOS) {
  //       _updateMobileBadge(count);
  //     } else if (Platform.isLinux || Platform.isWindows) {
  //       _updateDesktopBadge(count);
  //     } else if (kIsWeb) {
  //       _updateWebBadge(count);
  //     }
  //   } else {
  //     removeBadge();
  //   }
  // }
  //   /// Elimina el badge en el ícono de la aplicación.
  // static void removeBadge() {
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     _removeMobileBadge();
  //   } else if (Platform.isLinux || Platform.isWindows) {
  //     _removeDesktopBadge();
  //   } else if (kIsWeb) {
  //     _updateWebBadge(0);
  //   }
  // }

  // // Implementación para dispositivos móviles (Android/iOS)
  // static void _updateMobileBadge(int count) {
  //   // Aquí puedes usar el paquete flutter_app_badger o similar
  //   // Ejemplo:
  //   // FlutterAppBadger.updateBadgeCount(count);
  // }

  // static void _removeMobileBadge() {
  //   // Aquí puedes usar el paquete flutter_app_badger o similar
  //   // Ejemplo:
  //   // FlutterAppBadger.removeBadge();
  // }

  // // Implementación para escritorio (Linux/Windows)
  // static void _updateDesktopBadge(int count) {
  //   // Aquí puedes implementar la lógica para mostrar un badge en el ícono
  //   // Utiliza un paquete como `win32` para Windows o `gtk` para Linux
  // }

  // static void _removeDesktopBadge() {
  //   // Lógica para eliminar el badge en escritorio
  // }

  // // Implementación para la web
  // static void _updateWebBadge(int count) {
  //   // Cambia el título del documento o el favicon
  //   if (count > 0) {
  //     // Document.title = "(${count}) Título de la Aplicación";
  //   } else {
  //     // Document.title = "Título de la Aplicación";
  //   }
  // }
}