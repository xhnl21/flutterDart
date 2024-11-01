// ignore_for_file: avoid_print

import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'model.dart';
// import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late final Box<Community> _productBox;
  bool _isInitialized = false;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<void> initialize() async {   
    if (!_isInitialized) {
      if (kIsWeb) {
        // Para la web, no es necesario especificar un directorio
        Hive.init('demo');
      } else {
        Directory appDocDir = Directory.current;
        var rs = '${appDocDir.path}/hive_export/';      
        // Para móvil y escritorio, usa el directorio de documentos
        Hive.init(rs);
      }  
      
      Hive.registerAdapter(CommunityAdapter()); // Registra el adaptador
      _productBox = await Hive.openBox<Community>('community');

      // Validar si la caja está vacía
      if (_productBox.isEmpty) {
        print('La caja está vacía.'); // O realiza alguna acción específica
        // Aquí puedes inicializar datos predeterminados si es necesario
      } else {
        print('La caja contiene datos.');
      }

      _isInitialized = true; // Marcar como inicializado
    }
  }

  Future<bool> isHiveBoxEmpty(String boxName) async {
    // Si _productBox es null, ábrelo
    if (!_isInitialized) {
      await initialize();
    }
    
    // Retorna si la caja está vacía
    return _productBox.isEmpty;
  }

  Future<bool> checkIfBoxIsEmpty() async {
    return await isHiveBoxEmpty('community');
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

  Future<void> insertData(data) async {
    var community = Hive.box<Community>('community');
    int lastId = community.isEmpty ? 0 : community.values.last.id;

    for (var item in data) {
      try {
        int age = int.parse(item[7].toString()); // Convertir string a int
        var person = Community(
          id: lastId + 1,  // Incrementa el ID
          name: item[0],
          lname: item[1],
          ci: item[2],
          phone: item[3],
          email: item[4],
          address: item[5],
          birthdate: item[6].toString(),
          age: age,
        );

        await community.add(person);
        // print('Persona añadida: $person');
        lastId++;  // Asegúrate de incrementar el ID
      } catch (e) {
        print('Error al convertir a int: ${item[7]} - $e');
      }
    }
  }

Future<void> insert(List<dynamic> data) async {
  var community = Hive.box<Community>('community');
  
  // Verificación de la longitud de data
  if (data.length < 8) {
    print('Error: Datos insuficientes. Se esperaban al menos 9 elementos, pero se recibieron ${data.length}.');
    return; // Salir del método si no hay suficientes datos
  }

  int lastId = community.isEmpty ? 0 : community.values.last.id;
  // print('Datos recibidos: $data'); // Para depuración
  try { 
    var person = Community(
      id: lastId + 1,  // Incrementa el ID
      name: data[0].toString(),
      lname: data[1].toString(),
      ci: data[2].toString(),
      phone: data[3].toString(),
      email: data[4].toString(),
      address: data[5].toString(),
      birthdate: data[6].toString(),
      age: int.parse(data[7].toString()),
    );
    await community.add(person);
    // print('Persona añadida: $person');
  } catch (e) {
    print('Error al insertar datos: $data - $e');
  }
}

  Future<void> update(List<dynamic> data, int index) async {
    Community? product;
    // Verifica si la caja contiene la clave productId
    final bool exists = _productBox.containsKey(index);
    if (exists) {
      // Obtiene el producto usando el ID
      product = _productBox.get(index); // Usa get para obtener el producto directamente
    } else {
      print('Product with ID $index not found.');
    }
    if (product != null) {
      // Actualizar las propiedades del producto
      product.name = data[1];
      product.lname = data[2];
      product.ci = data[3];
      product.phone = data[4];
      product.email = data[5];
      product.address = data[6];
      product.birthdate = data[7];
      product.age = int.parse(data[8].toString()); // Asegúrate de que esto sea un int
      await _productBox.putAt(index, product); // Usa el ID original como clave
    }
  }

  List<Community> get() {
    return _productBox.values.toList();
  }

  Future<void> delete(int index, int indexz) async {
    await _productBox.deleteAt(indexz);
    print('Deleted product at index: $index');
  }

  Future<void> clearAllData() async {
    await initialize();
    var communityBox = Hive.box<Community>('community');
    
    // Elimina todos los datos de la caja
    await communityBox.clear();
    print('Todos los datos han sido eliminados de la caja.');
  }

  Future<void> close() async {
    await _productBox.close();
    _isInitialized = false;
  }
}
