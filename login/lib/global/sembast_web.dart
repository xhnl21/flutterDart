// // ignore_for_file: avoid_print

// import 'dart:async';

// import 'package:sembast/sembast_io.dart';
// import 'package:sembast_web/sembast_web.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// // ignore: unused_import, avoid_web_libraries_in_flutter
// // import 'dart:html' as html;
// // import 'dart:convert';

// class DatabaseHelper {
//   // Define la tienda (store)
//   static String tabla = 'furion';
//   final StoreRef<int, Map<String, Object?>> store = intMapStoreFactory.store(tabla);
//   late Database db;
  
//   Future<Database> typePlataformApp() async {
//       // Abre la base de datos usando la plataforma adecuada
//     if (kIsWeb) {
//       db = await databaseFactoryWeb.openDatabase(tabla);
//     } else {
//       db = await databaseFactoryIo.openDatabase(tabla); // Usa Sembast IO para dispositivos móviles
//     }
//     return db;
//   }

//   Future<DatabaseFactory> typeFactoryPlataformApp() async {
//     return kIsWeb ? databaseFactoryWeb : databaseFactoryIo;
//   }


//   // Future<void> exportDatabase() async {
//   //   // Database db;
//   //   final db = await typePlataformApp();

//   //   // Leer todos los registros
//   //   final finder = Finder();
//   //   final recordSnapshots = await store.find(db, finder: finder);

//   //   // Crear contenido SQL
//   //   List<String> sqlQueries = [];

//   //   // Consulta para crear la base de datos (ajusta según tus necesidades)
//   //   sqlQueries.add('CREATE DATABASE $tabla;');

//   //   // Consulta para crear la tabla
//   //   sqlQueries.add('CREATE TABLE $tabla (key INTEGER PRIMARY KEY, name TEXT, price REAL);');

//   //   // Consultas para insertar los datos
//   //   for (var snapshot in recordSnapshots) {
//   //     sqlQueries.add('INSERT INTO $tabla (key, name, price) VALUES (${snapshot.key}, "${snapshot.value['name']}", ${snapshot.value['price']});');
//   //   }

//   //   // Crear el contenido del archivo SQL
//   //   String dbContent = sqlQueries.join('\n');

//   //   // Exportar dependiendo de la plataforma
//   //   if (kIsWeb) {
//   //     final blob = html.Blob([dbContent], 'text/plain');
//   //     final url = html.Url.createObjectUrlFromBlob(blob);
      
//   //     // Crear un enlace de descarga
//   //     html.AnchorElement(href: url)
//   //       ..setAttribute('download', 'database_export.sql')
//   //       ..click();
      
//   //     html.Url.revokeObjectUrl(url); // Revoca el objeto URL
//   //   } else {
//   //     // Lógica de exportación para dispositivos móviles
//   //     print('Exported data for mobile: $dbContent');
//   //   }

//   //   await db.close();
//   // }

//   // Future<void> exportDatabaseJSON() async {
//   //   final db = await typePlataformApp();

//   //   // Leer todos los registros
//   //   final finder = Finder();
//   //   final recordSnapshots = await store.find(db, finder: finder);

//   //   // Convertir los registros a un formato que puedas exportar
//   //   List<Map<String, dynamic>> records = recordSnapshots.map((snapshot) {
//   //     return {
//   //       'key': snapshot.key,
//   //       'value': snapshot.value,
//   //     };
//   //   }).toList();

//   //   // Exportar dependiendo de la plataforma
//   //   if (kIsWeb) {
//   //     // Lógica de exportación para la web
//   //     final json = jsonEncode(records); // Serializa a JSON

//   //     // Asegúrate de que la variable 'html' esté correctamente referenciada
//   //     final blob = html.Blob([json], 'application/json');
//   //     final url = html.Url.createObjectUrlFromBlob(blob);
      
//   //     // Crear un enlace de descarga
//   //     html.AnchorElement(href: url)
//   //       ..setAttribute('download', 'database_export.json')
//   //       ..click();
      
//   //     html.Url.revokeObjectUrl(url); // Revoca el objeto URL
//   //   } else {
//   //     // Lógica de exportación para dispositivos móviles
//   //     print('Exported data for mobile: $records');
//   //   }

//   //   await db.close();
//   // }

//   Future<void> add(String name, double price) async {
//     // Usar el factory adecuado según la plataforma
//     final factory = await typeFactoryPlataformApp();
    
//     // Abre la base de datos
//     final db = await factory.openDatabase(tabla);

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

//       // Agregar un nuevo registro
//       await store.add(db, {
//         'id': newId, // Tu campo 'id'
//         'name': name,
//         'price': price,
//         'created_at': DateTime.now().toIso8601String(),
//         'updated_at': '',
//       });
//       // print('Added record with id: $newId');

//       // Leer el registro (opcional, para verificar la adición)
//       // var value = await store.record(newId).get(db);
//       // print('Record: $value');
//     } catch (e) {
//       print('Error adding record: $e');
//     } finally {
//       // Cerrar la base de datos
//       await db.close();
//     }
//   }

//   Future<void> update(int id, String name, double price) async {
//     // Usar el factory adecuado según la plataforma
//     final factory = await typeFactoryPlataformApp();
    
//     // Abre la base de datos
//     final db = await factory.openDatabase(tabla);

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

//   Future<List<RecordSnapshot<int, Map<String, Object?>>>> readRecords() async {
//     // Usar el factory adecuado según la plataforma
//     final factory = await typeFactoryPlataformApp();

//     // Abre la base de datos
//     final db = await factory.openDatabase(tabla);

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

//   Future<void> delete(int id) async {
//     // Usar el factory adecuado según la plataforma
//     final factory = await typeFactoryPlataformApp();
    
//     // Abre la base de datos
//     final db = await factory.openDatabase(tabla);

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
// }