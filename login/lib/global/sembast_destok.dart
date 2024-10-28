// // ignore_for_file: avoid_print, unused_import

// import 'dart:convert';
// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sembast/sembast_io.dart';
// import 'package:sembast_web/sembast_web.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// // ignore: avoid_web_libraries_in_flutter
// // import 'dart:html' as html;

// class DatabaseHelper {
//   static String tabla = 'test_store';
//   final StoreRef<int, Map<String, dynamic>> store = intMapStoreFactory.store(tabla);

//   Future<Database> openDatabase() async {
//     if (kIsWeb) {
//       return await databaseFactoryWeb.openDatabase(tabla);
//     } else {
//       final directory = await getApplicationDocumentsDirectory();
//       final dbPath = join(directory.path, tabla);
//       return await databaseFactoryIo.openDatabase(dbPath);
//     }
//   }

//   Future<void> exportDatabase() async {
//     final db = await openDatabase();
//     StringBuffer sqlBuffer = StringBuffer();

//     try {
//       // Crear la instrucción CREATE TABLE
//       sqlBuffer.writeln('CREATE TABLE $tabla (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL);');

//       // Leer todos los registros
//       final records = await store.find(db);
//       for (var record in records) {
//         // Crear la instrucción INSERT para cada registro
//         sqlBuffer.writeln('INSERT INTO $tabla (id, name, price) VALUES (${record.key}, \'${record.value['name']}\', ${record.value['price']});');
//       }

//       // Guardar en un archivo .sql para escritorio
//       final directory = await getApplicationDocumentsDirectory();
//       final sqlPath = join(directory.path, 'exported_database.sql');
//       final sqlFile = File(sqlPath);
//       await sqlFile.writeAsString(sqlBuffer.toString());
//       print('Database exported to $sqlPath');
//     } catch (e) {
//       print('Error exporting database: $e');
//     } finally {
//       await db.close();
//     }
//   }

//   // Future<void> exportDatabase() async {
//   //   final db = await openDatabase();
//   //   StringBuffer sqlBuffer = StringBuffer();

//   //   try {
//   //     // Crear la instrucción CREATE TABLE
//   //     sqlBuffer.writeln('CREATE TABLE $tabla (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL);');

//   //     // Leer todos los registros
//   //     final records = await store.find(db);
//   //     for (var record in records) {
//   //       // Crear la instrucción INSERT para cada registro
//   //       sqlBuffer.writeln('INSERT INTO $tabla (id, name, price) VALUES (${record.key}, \'${record.value['name']}\', ${record.value['price']});');
//   //     }

//   //     if (kIsWeb) {
//   //       // Exportar para la web
//   //       final blob = html.Blob([sqlBuffer.toString()], 'text/plain');
//   //       final url = html.Url.createObjectUrlFromBlob(blob);
//   //       final anchor = html.AnchorElement(href: url)
//   //         ..setAttribute('download', 'exported_database.sql')
//   //         ..click();
//   //       html.Url.revokeObjectUrl(url);
//   //     } else {
//   //       // Guardar en un archivo .sql para escritorio
//   //       final directory = await getApplicationDocumentsDirectory();
//   //       final sqlPath = join(directory.path, 'exported_database.sql');
//   //       final sqlFile = File(sqlPath);
//   //       await sqlFile.writeAsString(sqlBuffer.toString());
//   //       print('Database exported to $sqlPath');
//   //     }
//   //   } catch (e) {
//   //     print('Error exporting database: $e');
//   //   } finally {
//   //     await db.close();
//   //   }
//   // }


//   Future<void> exportDatabaseJSON() async {
//     final db = await openDatabase();
//     try {
//       // Leer todos los registros
//       final records = await store.find(db);

//       // Convertir registros a JSON
//       final List<Map<String, dynamic>> jsonRecords = records.map((snapshot) {
//         return {
//           'id': snapshot.key,
//           ...snapshot.value,
//         };
//       }).toList();

//       // Convertir a cadena JSON
//       String jsonString = jsonEncode(jsonRecords);

//       // Guardar en un archivo
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File(join(directory.path, 'database_export.json'));
//       await file.writeAsString(jsonString);
//       print('Database exported to ${file.path}');
//     } catch (e) {
//       print('Error exporting database: $e');
//     } finally {
//       await db.close();
//     }
//   }

//   Future<void> add(String name, double price) async {
//     final db = await openDatabase();
//     try {
//       final recordSnapshots = await store.find(db);
//       int newId = 1; // Por defecto, comenzamos en 1

//       if (recordSnapshots.isNotEmpty) {
//         // Encuentra el id máximo existente y suma 1
//         final existingIds = recordSnapshots
//             .map((snapshot) => snapshot.value['id'] as int?) // Especificar que puede ser null
//             .where((id) => id != null) // Filtrar los null
//             .cast<int>(); // Convertir a List<int> para usar reduce
//         if (existingIds.isNotEmpty) {
//           newId = existingIds.reduce((a, b) => a > b ? a : b) + 1; // Obtener el máximo
//         }
//       }    
//       await store.add(db, {
//         'id': newId, // Tu campo 'id'
//         'name': name,
//         'price': price,
//         'created_at': DateTime.now().toIso8601String(),
//         'updated_at': '',
//       });
//       print('Added record: $name');
//     } catch (e) {
//       print('Error adding record: $e');
//     } finally {
//       await db.close();
//     }
//   }

//   Future<void> update(int id, String name, double price) async {
//     final db = await openDatabase();

//     try {
//       // Buscar el registro por id
//       var record = await store.record(id).get(db);

//       if (record != null) {
//         // Actualizar los campos deseados
//         await store.record(id).update(db, {
//           'name': name,
//           'price': price,
//           'created_at': record['created_at'],
//           'updated_at': DateTime.now().toIso8601String(),
//         });
//         print('Updated record with id: $id');
//       } else {
//         print('Record with id: $id not found');
//       }
//     } catch (e) {
//       print('Error updating record: $e');
//     } finally {
//       // Cerrar la base de datos
//       await db.close();
//     }
//   }

//   Future<void> delete(int id) async {
//     final db = await openDatabase();

//     try {
//       // Buscar el registro por id
//       var record = await store.record(id).get(db);
      
//       if (record != null) {
//         // Eliminar el registro
//         await store.record(id).delete(db);
//         print('Deleted record with id: $id');
//       } else {
//         print('Record with id: $id not found');
//       }
//     } catch (e) {
//       print('Error deleting record: $e');
//     } finally {
//       // Cerrar la base de datos
//       await db.close();
//     }
//   }

//   Future<List<RecordSnapshot<int, Map<String, Object?>>>> readRecords() async {
//     // Usar el factory adecuado según la plataforma
//     final db = await openDatabase();

//     // // Abre la base de datos
//     // final db = await factory.openDatabase(tabla);

//     try {
//       // Leer todos los registros ordenados por 'name'
//       final finder = Finder(sortOrders: [SortOrder('id')]);
//       final recordSnapshots = await store.find(db, finder: finder);

//       // // Imprimir todos los registros (opcional)
//       // for (var snapshot in recordSnapshots) {
//       //   print('Record: ${snapshot.value} with key: ${snapshot.key}');
//       // }

//       return recordSnapshots;
//     } catch (e) {
//       print('Error reading records: $e');
//       return []; // Devuelve una lista vacía en caso de error
//     } finally {
//       // Cerrar la base de datos
//       await db.close();
//     }
//   }
// }