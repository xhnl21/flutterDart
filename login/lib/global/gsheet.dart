// ignore_for_file: avoid_print, unnecessary_null_comparison

// google sheets
import 'package:gsheets/gsheets.dart';
// import 'dart:io' show Directory, Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
// import 'dart:html' as html;
import 'package:sembast/sembast_io.dart'; // Para la web
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Task {
  int id;
  String name;

  Task({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  Task.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'];
}
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  late Database _database;

  Future<Database> get database async {
    print(kIsWeb);
    if (_database != null) return _database;
    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    var dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'tasks.db');
    return await databaseFactoryIo.openDatabase(path);
  }
}
class TaskRepository {
  final StoreRef<int, Map<String, dynamic>> _store =
      intMapStoreFactory.store('tasks');

  Future<void> addTask(Task task) async {
    final db = await DatabaseHelper().database;
    await _store.add(db, task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await DatabaseHelper().database;
    final snapshot = await _store.find(db);
    return snapshot.map((record) => Task.fromMap(record.value)).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await DatabaseHelper().database;
    await _store.record(task.id).update(db, task.toMap());
  }

  Future<void> deleteTask(int id) async {
    final db = await DatabaseHelper().database;
    await _store.record(id).delete(db);
  }
}


class Gsheet {
  // static Future<Database> initDB() async {
  //   String path = '';
  //   try {
  //     print(kIsWeb);
  //     // if (kIsWeb) {
  //     //   path = await getDatabasesPath();
  //     //   databaseFactory = databaseFactoryFfiWeb;
  //     // } 
  //     // else if (Platform.isAndroid || Platform.isIOS) {
  //     //   // Móviles: No es necesario inicializar, ya está listo en Android/iOS
  //     //   path = await getDatabasesPath();
  //     // } else if (Platform.isLinux || Platform.isWindows) {
  //     //   path = Directory.current.path;
  //     //   sqfliteFfiInit();
  //     //   databaseFactory = databaseFactoryFfi;
  //     // } else {
  //     //   throw UnsupportedError("Plataforma no soportada");
  //     // }

  //     // Asegurarse de que la ruta de la base de datos está configurada
  //     if (path.isEmpty) {
  //       print("Error: No se pudo determinar la ruta de la base de datos.");
  //       return Future.error('Failed to initialize database');
  //     }

  //     print("Ruta de la base de datos: $path");
  //     // return await openDatabase(
  //     //   join(path, 'example.db'),
  //     //   onCreate: (db, version) async {
  //     //     await db.execute('''
  //     //       CREATE TABLE users(
  //     //         id INTEGER PRIMARY KEY AUTOINCREMENT,
  //     //         name TEXT,
  //     //         age INTEGER
  //     //       )
  //     //     ''');
  //     //   },
  //     //   version: 1,
  //     // );
  //     // return await databaseFactory.openDatabase(
  //     //   join(path, 'example.db'), 
  //     //   options: OpenDatabaseOptions(
  //     //     onCreate: (db, version) async {
  //     //       await db.execute('''
  //     //         CREATE TABLE users(
  //     //           id INTEGER PRIMARY KEY AUTOINCREMENT,
  //     //           name TEXT,
  //     //           age INTEGER
  //     //         )
  //     //       ''');
  //     //     },
  //     //     version: 1,
  //     //   )
  //     // );      
  //   } catch (e) {
  //     print('Error initializing database: $e');
  //     return Future.error('Failed to initialize database');
  //   }
  // }
  // static Future<Database> initDBX() async {
  //   String path = '';
  //   // if (kIsWeb) {
  //   //   // Definir la ruta manualmente al directorio del proyecto
  //   //   path = await getDatabasesPath();
  //   //   // Inicializar Hive para la Web
  //   //    databaseFactory = databaseFactoryFfiWeb;
  //   // }
  //   //  else if (Platform.isAndroid || Platform.isIOS) {
  //   //   // No es necesario hacer nada, sqflite ya está listo en móvil
  //   // } else if (Platform.isLinux || Platform.isWindows) {
  //   //   // Definir la ruta manualmente al directorio del proyecto
  //   //   path = Directory.current.path; // Directorio actual del proyecto

  //   //   // Inicializar sqflite_common_ffi en Linux o Windows
  //   //   sqfliteFfiInit();
  //   //   databaseFactory = databaseFactoryFfi;
  //   // }

    
  //   print("Ruta de la base de datos: $path");
  //   // return openDatabase(join(path, 'example.db'), onCreate: (db, version) async {
  //   //     await db.execute('''
  //   //       CREATE TABLE users(
  //   //         id INTEGER PRIMARY KEY AUTOINCREMENT,
  //   //         name TEXT,
  //   //         age INTEGER
  //   //       )
  //   //     '''); // Crear la tabla 'users'
  //   //   },
  //   //   version: 1,
  //   // );
  // }

  // static Future<void> insertUser(Database db, String name, int age) async {
  //   await db.insert(
  //     'users', // Nombre de la tabla
  //     {'name': name, 'age': age}, // Datos a insertar
  //     conflictAlgorithm: ConflictAlgorithm.replace, // Si ya existe, reemplaza
  //   );
  // }

  // static Future<List<Map<String, dynamic>>> getUsers(Database db) async {
  //   return await db.query('users'); // Consulta todos los registros
  // }



  static const String title = 'master';

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

  static Future<List<Object>> dataSheet() async {
    try {
      var data = await gsheetsConnection();
      // print(data);
      return data;
    } catch (e) {
      print('Error accessing spreadsheet: $e');
      return [];
    }
  }
}