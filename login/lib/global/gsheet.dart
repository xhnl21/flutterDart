// ignore_for_file: avoid_print, unnecessary_null_comparison

// google sheets

import 'package:gsheets/gsheets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:login/model/community.dart';


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
    try {
      final sheet = await gsCnn();
      var data = await sheet.values.allRows();
      final dbHelper = await syncDataHive();
      bool isEmpty = await dbHelper.checkIfBoxIsEmpty();
      if (isEmpty) {
        await insertTransationHive(data);
        // print(data);
        await readSheet();
      }
      return data;
    } catch (e) {
      print('Error accessing spreadsheet readSheet(): $e');
      return [];
    }
  }

  static Future<void> insertSheet(data, row) async {
    try {
      final sheet = await gsCnn();
      await sheet.values.insertRow(row, data);
    } catch (e) {
       print('method::insertSheet, Error accessing spreadsheet: $e');
    }
  }

  static Future<void> updateSheet(data, row) async {
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
  }

  static Future<void> deleteSheet(row) async {
    try {
      final sheet = await gsCnn();
       await sheet.deleteRow(row);
    } catch (e) {
       print('method::insertSheet, Error accessing spreadsheet: $e');
    }
  }  
}