import 'package:hive/hive.dart';

// part 'model.g.dart'; // Asegúrate de generar el código de Hive

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
  String name;

  @HiveField(1)
  String lname;

  @HiveField(2)
  String ci;

  @HiveField(3)
  String phone;
  
  @HiveField(4)
  String address;

  @HiveField(5)
  String birthdate;

  @HiveField(6)
  String age;

  Community({
    required this.name, 
    required this.lname, 
    required this.ci, 
    required this.phone, 
    required this.address, 
    required this.birthdate,
    required this.age
  });
}