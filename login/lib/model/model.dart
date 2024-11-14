// ignore_for_file: non_constant_identifier_names

// import 'dart:ffi';

import 'package:hive/hive.dart';

part 'model.g.dart'; // Asegúrate de generar el código de Hive

@HiveType(typeId: 0)
class Community {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String lname;

  @HiveField(3)
  String ci;

  @HiveField(4)
  String phone;
  
  @HiveField(5)
  String email;

  @HiveField(6)
  String address;

  @HiveField(7)
  String birthdate;

  @HiveField(8)
  int age;

  Community({
    required this.id, 
    required this.name, 
    required this.lname, 
    required this.ci, 
    required this.phone, 
    required this.email, 
    required this.address, 
    required this.birthdate,
    required this.age
  });
}

@HiveType(typeId: 1)
class Offline {
  @HiveField(0)
  int id;

  @HiveField(1)
  String action;

  @HiveField(2)
  String data;

  @HiveField(3)
  String status;

  @HiveField(4)
  String create_at;

  @HiveField(5)
  String update_at;  

  Offline({
    required this.id, 
    required this.action,
    required this.status, 
    required this.data, 
    required this.create_at, 
    required this.update_at, 
  });
}

@HiveType(typeId: 2)
class Offlines {
  @HiveField(0)
  int id;

  @HiveField(1)
  String action;

  @HiveField(2)
  String data;

  @HiveField(3)
  String status;

  @HiveField(4)
  String create_at;

  @HiveField(5)
  String update_at;  

  Offlines({
    required this.id, 
    required this.action,
    required this.status, 
    required this.data, 
    required this.create_at, 
    required this.update_at, 
  });
}

@HiveType(typeId: 3)
class Createsheet {
  @HiveField(0)
  int id;

  @HiveField(1)
  String cedula;

  @HiveField(2)
  String email;

  @HiveField(3)
  String description;

  @HiveField(4)
  String rol;

  @HiveField(5)
  String name_sheet;
  
  @HiveField(6)
  String id_sheet;

  @HiveField(7)
  String export_pdf;

  @HiveField(8)
  String export_excel;

  @HiveField(9)
  String export_db;

  @HiveField(10)
  String create_at;
  
  @HiveField(11)
  String update_at;

  Createsheet({
    required this.id, 
    required this.cedula, 
    required this.email, 
    required this.description, 
    required this.rol, 
    required this.name_sheet, 
    required this.id_sheet, 
    required this.export_pdf, 
    required this.export_excel,
    required this.export_db,
    required this.create_at,
    required this.update_at
  });
}
