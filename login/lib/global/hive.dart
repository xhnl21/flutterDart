// ignore_for_file: avoid_print
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'model.dart';
// import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late final Box<Product> _productBox;
  bool _isInitialized = false;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<void> initialize() async {
    Directory appDocDir = Directory.current;    
    var rs = '${appDocDir.path}/hive_export/';
    if (!_isInitialized) {
      if (kIsWeb) {
        // Para la web, no es necesario especificar un directorio
        Hive.init(rs);
      } else {
        // Para móvil y escritorio, usa el directorio de documentos
        Hive.init(rs);
      }  
      Hive.registerAdapter(ProductAdapter()); // Registra el adaptador
      _productBox = await Hive.openBox<Product>('products');
      _isInitialized = true;
    }
  }

  Future<void> exportHiveDatabase() async {
    Directory appDocDir = Directory.current; // Esto apunta al directorio donde se ejecuta el script
    String hiveDirPath = appDocDir.path; // Ruta completa del archivo

    // Nombre del archivo de la caja de Hive
    String hiveFileName = 'demo.hive'; // Cambia esto al nombre de tu caja
    String hiveFilePath = join(hiveDirPath, hiveFileName);

    // Define la ruta de destino para la exportación
    String exportPath = '${appDocDir.path}/hive_export';
    Directory exportDir = Directory(exportPath);
    
    // Crea el directorio de exportación si no existe
    if (!await exportDir.exists()) {
      await exportDir.create();
    }

    // Verifica si el archivo de Hive existe
    if (!await File(hiveFilePath).exists()) {
      // Si el archivo no existe, crea la caja y añade algunos datos.
      print('El archivo de Hive no existe: $hiveFilePath. Creando la caja y añadiendo datos.');
      await createEmptyTextFile(hiveFileName);
    }

    // Verifica si el archivo de Hive existe
    if (await File(hiveFilePath).exists()) {
      try {
        // Copia el archivo de Hive a la ruta de exportación
        String newPath = join(exportPath, '${basenameWithoutExtension(hiveFileName)}.db');
        await File(hiveFilePath).copy(newPath);
        print('Exportado: $hiveFilePath a $newPath');
      } catch (e) {
        print('Error al exportar la base de datos: $e');
      }
    } else {
      print('El archivo de Hive no existe: $hiveFilePath');
    }
  }

  String basenameWithoutExtension(String path) {
    return basename(path).split('.').first; // Obtiene el nombre sin la extensión
  }

  Future<void> createEmptyTextFile(String fileName) async {
    Directory projectDir = Directory.current; // Esto apunta al directorio donde se ejecuta el script
    String filePath = '${projectDir.path}/$fileName'; // Ruta completa del archivo
    try {
      File file = File(filePath);
      await file.create(); // Crea el archivo vacío
      print('Archivo creado: $filePath');
    } catch (e) {
      print('Ocurrió un error al crear el archivo: $e');
    }
  }

// Future<void> exportDatabaseToJson() async {
//   // Abre tu caja de Hive
//   var box = await Hive.openBox('your_box_name');

//   // Lee todos los registros
//   List<Map<String, dynamic>> records = box.toMap().values.toList();

//   // Convierte los registros a JSON
//   String jsonData = jsonEncode(records);

//   // Obtén el directorio de documentos para guardar el archivo
//   Directory appDocDir = await getApplicationDocumentsDirectory();
//   String filePath = '${appDocDir.path}/hive_export.json';
  
//   // Escribe el archivo JSON
//   File file = File(filePath);
//   await file.writeAsString(jsonData);

//   print('Base de datos exportada a: $filePath');
// }


  Future<void> add(String name, double price) async {
    final product = Product(name: name, price: price);
    await _productBox.add(product);
    print('Added product: ${product.name}');
  }

  List<Product> get() {
    return _productBox.values.toList();
  }

  Future<void> update(int index, String name, double price) async {
    final product = _productBox.getAt(index);
    if (product != null) {
      product.name = name;
      product.price = price;
      await _productBox.putAt(index, product);
      print('Updated product at index: $index');
    }
  }

  Future<void> delete(int index) async {
    await _productBox.deleteAt(index);
    print('Deleted product at index: $index');
  }

  Future<void> close() async {
    await _productBox.close();
    _isInitialized = false;
  }
}