// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'package:hive/hive.dart';
// import 'package:path/path.dart';
import 'model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
class OfflinesAction {
  static final OfflinesAction _instance = OfflinesAction._internal();
  late final Box<Offlines> _offlineBox;
  bool _isInitialized = false;

  factory OfflinesAction() {
    return _instance;
  }

  OfflinesAction._internal();

  Future<void> initialize() async {
    if (_isInitialized) return; // Evita inicializar si ya está hecho

    if (kIsWeb) {
      Hive.init('offlines'); // Para la web
    } else {
      Directory appDocDir = Directory.current;
      var rs = '${appDocDir.path}/hive_export/';
      Hive.init(rs); // Para móvil y escritorio
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(OfflinesAdapter());
    }

    // if (!Hive.isBoxOpen('offline')) { // Verifica si la caja ya está abierta
      _offlineBox = await Hive.openBox<Offlines>('offlines');
    // }

    _isInitialized = true; // Marca como inicializado
    print(_offlineBox.isEmpty ? 'La caja está vacía.' : 'La caja contiene datos.');
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize(); // Verifica si ya está inicializada
    }
  }

  Future<void> insert(List<dynamic> data) async {
    var offline = Hive.box<Offlines>('offlines');
    
    // Verificación de la longitud de data
    if (data.length < 3) {
      print('Error: Datos insuficientes. Se esperaban al menos 4 elementos, pero se recibieron ${data.length}.');
      return; // Salir del método si no hay suficientes datos
    }

    int lastId = offline.isEmpty ? 0 : offline.values.last.id;
    // print('Datos recibidos: $data'); // Para depuración
    try { 
      var person = Offlines(
        id: lastId + 1,  // Incrementa el ID
        action: data[0].toString(),
        data: data[1].toString(),
        status: data[2].toString(),
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
    Offlines? product;
    // Verifica si la caja contiene la clave productId
    final bool exists = _offlineBox.containsKey(index);
    if (exists) {
      // Obtiene el producto usando el ID
      product = _offlineBox.get(index); // Usa get para obtener el producto directamente
    } else {
      print('Product with ID $index not found.');
    }
    if (product != null) {
      product.status = data[3].toString();
      product.update_at = DateTime.now().toIso8601String();
      await _offlineBox.putAt(index, product); // Usa el ID original como clave
    }
  }

  Future<List<Offlines>> get() async {
    await ensureInitialized(); // Asegura que está inicializado antes de usar _offlineBox
    var rs = _offlineBox.values.toList();
    return rs;
  }

  Future<void> clearAllData() async {
    await ensureInitialized();
    var communityBox = Hive.box<Offlines>('offlines');
    
    // Elimina todos los datos de la caja
    await communityBox.clear();
    print('Todos los datos han sido eliminados de la caja.');
  }  

  void closeAllBoxes() {
    if (Hive.isBoxOpen('offlines')) Hive.box('offlines').close();
  }
}