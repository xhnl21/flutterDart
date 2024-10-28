import 'package:hive/hive.dart';

part 'model.g.dart'; // Asegúrate de generar el código de Hive

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  String name;

  @HiveField(1)
  double price;

  Product({required this.name, required this.price});
}

@HiveType(typeId: 1)
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