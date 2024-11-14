// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'package:hive/hive.dart';
// import 'package:path/path.dart';
import 'model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
class CreateSheets {
  static final CreateSheets _instance = CreateSheets._internal();
  late final Box<Createsheet> _offlineBox;
  bool _isInitialized = false;
  final String _box = "createsheet";

  factory CreateSheets() {
    return _instance;
  }

  CreateSheets._internal();

  Future<void> initialize() async {
    if (_isInitialized) return; // Evita inicializar si ya está hecho

    if (kIsWeb) {
      Hive.init(_box); // Para la web
    } else {
      Directory appDocDir = Directory.current;
      var rs = '${appDocDir.path}/hive_export/';
      Hive.init(rs); // Para móvil y escritorio
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CreatesheetAdapter());
    }

    if (!Hive.isBoxOpen('createsheet')) { // Verifica si la caja ya está abierta
      _offlineBox = await Hive.openBox<Createsheet>("createsheet");
    }

    _isInitialized = true; // Marca como inicializado
    print(_offlineBox.isEmpty ? 'La caja está vacía.' : 'La caja contiene datos.');
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize(); // Verifica si ya está inicializada
    }
  }

  Future<bool> getCounRow() async{
    CreateSheets().initialize();
    var community = Hive.box<Createsheet>("createsheet");
    bool lastId = community.isEmpty ? false : true;
    return lastId;
  }

  Future<bool> checkIfBoxIsEmpty() async {
    var box = await Hive.openBox<Createsheet>("createsheet");
    return box.isEmpty;
  }

  Future<void> insertData(data) async {
    CreateSheets().initialize();
    // await Hive.deleteBoxFromDisk("createsheet");
    print(data);
    var community = Hive.box<Createsheet>("createsheet");
    int lastId = community.isEmpty ? 0 : community.values.last.id;
    for (var item in data) {
      try {
        var person = Createsheet(
          id: lastId + 1,  // Incrementa el ID
          cedula: item[0].toString(),
          email: item[1].toString(),
          description: item[2].toString(),
          rol: item[3].toString(),
          name_sheet: item[4].toString(),
          id_sheet: item[5].toString(),
          export_pdf: item[6].toString(),
          export_excel: item[7].toString(),
          export_db: item[8].toString(),
          create_at: DateTime.now().toIso8601String(),
          update_at: '',
        );
        print(person.create_at);
        await community.add(person);
        print('Persona añadida: $person');
        lastId++;  // Asegúrate de incrementar el ID
      } catch (e) {
        print('Error al convertir a int: ${item[7]} - $e');
      }
    }
  }

  Future<void> insert(List<dynamic> data) async {
    var offline = Hive.box<Createsheet>(_box);
    
    // Verificación de la longitud de data
    if (data.length < 3) {
      print('Error: Datos insuficientes. Se esperaban al menos 4 elementos, pero se recibieron ${data.length}.');
      return; // Salir del método si no hay suficientes datos
    }

    int lastId = offline.isEmpty ? 0 : offline.values.last.id;
    // print('Datos recibidos: $data'); // Para depuración
    try { 
      var person = Createsheet(
        id: lastId + 1,  // Incrementa el ID
        cedula: data[0].toString(),
        email: data[1].toString(),
        description: data[2].toString(),
        rol: data[3].toString(),
        name_sheet: data[4].toString(),
        id_sheet: data[5].toString(),
        export_pdf: data[6].toString(),
        export_excel: data[7].toString(),
        export_db: data[8].toString(),
        create_at: DateTime.now().toIso8601String(),
        update_at: '',
      );
      await offline.add(person);
      // print('Persona añadida: $person');
    } catch (e) {
      print('Error al insertar datos: $data - $e');
    }
  }

  Future<void> update(List<dynamic> data, int index) async {
    Createsheet? product;
    // Verifica si la caja contiene la clave productId
    final bool exists = _offlineBox.containsKey(index);
    if (exists) {
      // Obtiene el producto usando el ID
      product = _offlineBox.get(index); // Usa get para obtener el producto directamente
    } else {
      print('Product with ID $index not found.');
    }
    if (product != null) {
      product.update_at = DateTime.now().toIso8601String();
      await _offlineBox.putAt(index, product); // Usa el ID original como clave
    }
  }

  Future<List<Createsheet>> get() async {
    await initialize(); // Asegura que está inicializado antes de usar _offlineBox
    var rs = _offlineBox.values.toList();
    return rs;
  }

  Future<void> delete(int index, int indexz) async {
    await _offlineBox.deleteAt(indexz);
    print('Deleted product at index: $index');
  }

  Future<void> clearAllData() async {
    await ensureInitialized();
    var communityBox = Hive.box<Createsheet>(_box);
    
    // Elimina todos los datos de la caja
    await communityBox.clear();
    print('Todos los datos han sido eliminados de la caja.');
  }  

  void closeAllBoxes() {
    if (Hive.isBoxOpen(_box)) Hive.box(_box).close();
  }
}