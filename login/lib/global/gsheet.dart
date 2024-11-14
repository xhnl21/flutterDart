// ignore_for_file: avoid_print, unnecessary_null_comparison

// google sheets
import 'dart:convert';

import 'package:gsheets/gsheets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:login/global/connectivity_service.dart';
import 'package:login/model/community_person.dart';
import 'package:login/model/offline_action.dart';
import 'package:login/model/offlines.dart';
class Gsheet {
  static const String title = 'master';

  static syncDataHive() async{
      await DatabaseHelper().initialize();
      return DatabaseHelper();
  }

  static insertTransationHive(data) async{
      final dbHelper = await syncDataHive();  
      var rsArray = [];
      // Añadir las filas excluyendo el encabezado (índice 0)
      for (var i = 1; i < data.length; i++) {
        rsArray.add(data[i]);
      }   
      // print(data);
      await dbHelper.insertData(rsArray);
  }

  static gsCnn() async{
    // Cargar las variables de entorno
    await dotenv.load();

    // Crear el JSON de credenciales usando interpolación
    final String credentials = '''
    {
      "type": "${dotenv.env['type']}",
      "project_id": "${dotenv.env['project_id']}",
      "private_key_id": "${dotenv.env['private_key_id']}",
      "private_key": "${dotenv.env['private_key']}",
      "client_email": "${dotenv.env['client_email']}",
      "client_id": "${dotenv.env['client_id']}",
      "auth_uri": "${dotenv.env['auth_uri']}",
      "token_uri": "${dotenv.env['token_uri']}",
      "auth_provider_x509_cert_url": "${dotenv.env['auth_provider_x509_cert_url']}",
      "client_x509_cert_url": "${dotenv.env['client_x509_cert_url']}",
      "universe_domain": "${dotenv.env['universe_domain']}"
    }
    ''';
    final String? spreadsheetId = dotenv.env['spreadsheet_id']; // Puede ser nulo

    if (spreadsheetId == null || spreadsheetId.isEmpty) {
      print('Error: spreadsheetId is not defined in .env');
      return []; // Retorna una lista vacía si no está definido
    }
    // var rows = []; // Para almacenar los datos
    final gsheets = GSheets(credentials);
    try {
      final ss = await gsheets.spreadsheet(spreadsheetId);
      return ss.worksheetByTitle(title);
    } catch (e) {
      print('Error accessing spreadsheet gsCnn(): $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }
  
  static Future<List<List<String>>> gsheetsConnection() async {
    // Cargar las variables de entorno
    await dotenv.load();

    // Crear el JSON de credenciales usando interpolación
    final String credentials = '''
    {
      "type": "${dotenv.env['type']}",
      "project_id": "${dotenv.env['project_id']}",
      "private_key_id": "${dotenv.env['private_key_id']}",
      "private_key": "${dotenv.env['private_key']}",
      "client_email": "${dotenv.env['client_email']}",
      "client_id": "${dotenv.env['client_id']}",
      "auth_uri": "${dotenv.env['auth_uri']}",
      "token_uri": "${dotenv.env['token_uri']}",
      "auth_provider_x509_cert_url": "${dotenv.env['auth_provider_x509_cert_url']}",
      "client_x509_cert_url": "${dotenv.env['client_x509_cert_url']}",
      "universe_domain": "${dotenv.env['universe_domain']}"
    }
    ''';
    final String? spreadsheetId = dotenv.env['spreadsheet_id']; // Puede ser nulo

    if (spreadsheetId == null || spreadsheetId.isEmpty) {
      print('Error: spreadsheetId is not defined in .env');
      return []; // Retorna una lista vacía si no está definido
    }
    // var rows = []; // Para almacenar los datos
    final gsheets = GSheets(credentials);
    try {
      final ss = await gsheets.spreadsheet(spreadsheetId);
      var sheet = ss.worksheetByTitle(title);
      if (sheet != null) {
        // Obtén los datos de la hoja
        // rows = await sheet.values.allRows();
        return await sheet.values.allRows();
      }
    } catch (e) {
      print('Error accessing spreadsheet: $e');
      return []; // Retorna una lista vacía en caso de error
    }
    return []; // Retorna una lista vacía en caso de error
  }

  static Future<List<Object>> readSheet() async {
    if (await ConnectivityService.isConnected()) {
      // try {
        final sheet = await gsCnn();      
        var data = await sheet.values.allRows();
        // print(data);
        final dbHelper = await syncDataHive();
        bool isEmpty = await dbHelper.checkIfBoxIsEmpty();
        // print(isEmpty);
        if (isEmpty) {
          await insertTransationHive(data);
          await readSheet();
        }
        return data;
      // } catch (e) {
      //   print('Error accessing spreadsheet readSheet(): $e');
      //   return [];
      // }
    } else {
      return [['Nombres', 'Apellidos', 'Cédulas', 'Teléfonos', 'Correos', 'Direcciónes', 'Fecha Nacimiento', 'edad']];
    }
  }

  static Future<void> insertSheet(data, row) async {
    if (await ConnectivityService.isConnected()) {
      try {
        final sheet = await gsCnn();
        await sheet.values.insertRow(row, data);
      } catch (e) {
        print('method::insertSheet, Error accessing spreadsheet: $e');
      }
    } else {
      var count = await countRow(row);
      var dat = ['create', json.encode([count, data]), 0];
      await OfflineAction().initialize();
      await OfflineAction().insert(dat);
      await OfflinesAction().initialize();
      await OfflinesAction().insert(dat);
    }
  }

  static Future<num> countRow(row) async{
    await OfflineAction().initialize();
    var rs = await OfflineAction().get();
    var create = [];
    for (var i = 0; i < rs.length; i++) {
      if(rs[i].status == '0'){
        if (rs[i].action == 'create') {
            create.add(rs[i]);
        }
      }
    }

    num dat = 0;
    if (create.isEmpty) {
      dat = row;
    } else {
      // var arr = List.from(create); // Esto crea una copia de `create` como una lista.
      // var ws = arr.last;
      // var dat = ws.data;
      // List<dynamic> dataArray = json.decode(dat); 
      // print(dataArray[0]);
      // dat = int.parse(dataArray[0]) + 1;
      // print(181);
      // print(row);
      // print(183);
      // print(create.length);
      // print(185);
      // // dat = row + create.length - 2;
      dat = row;
    }
    return dat;  
  }

  static Future<void> updateSheet(data, row) async {
    if (await ConnectivityService.isConnected()) {
      try {
        final sheet = await gsCnn();
        await sheet.values.insertValue(data[1], row: row, column: 1);
        await sheet.values.insertValue(data[2], row: row, column: 2);
        await sheet.values.insertValue(data[3], row: row, column: 3);
        await sheet.values.insertValue(data[4], row: row, column: 4);
        await sheet.values.insertValue(data[5], row: row, column: 5);
        await sheet.values.insertValue(data[6], row: row, column: 6);
        await sheet.values.insertValue(data[7], row: row, column: 7);
        await sheet.values.insertValue(data[8], row: row, column: 8);
      } catch (e) {
        print('method::insertSheet, Error accessing spreadsheet: $e');
      }
    } else {
      var count = await countRow(row);
      var dat = ['update', json.encode([count, data]), 0];
      await OfflineAction().initialize();
      await OfflineAction().insert(dat);
      await OfflinesAction().initialize();
      await OfflinesAction().insert(dat);      
    }
  }

  static Future<void> deleteSheet(row) async {
    if (await ConnectivityService.isConnected()) {
      try {
        final sheet = await gsCnn();
        await sheet.deleteRow(row);
      } catch (e) {
        print('method::insertSheet, Error accessing spreadsheet: $e');
      }
    } else {
      var dat = ['delete', json.encode([row]), 0];
      await OfflineAction().initialize();
      await OfflineAction().insert(dat);
      await OfflinesAction().initialize();
      await OfflinesAction().insert(dat);      
    }
  }
}