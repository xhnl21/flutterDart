// ignore_for_file: file_names, unused_import, avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';

import 'package:login/global/gsheet.dart';
// import 'package:gsheets/gsheets.dart';
class BadgerScreen extends StatefulWidget {
  const BadgerScreen({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.person_off, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  
  @override
  State<BadgerScreen> createState() => _BadgerScreenState();
}

class _BadgerScreenState extends State<BadgerScreen> {
  List<List<dynamic>>? rows; // Para almacenar los datos
  bool isLoading = true; // Para mostrar el estado de carga
  
  @override
  void initState() {
    super.initState();
    loadGsheetData(); // Cargar datos al iniciar
  }
  Future<void> loadGsheetData() async {
    try {
      var fetchedRows = await Gsheet.readSheet(); // Esperar a que se complete
      setState(() {
        rows = fetchedRows.cast<List>(); // Actualizar el estado con los datos
        isLoading = false; // Cambiar el estado de carga
      });
      print(rows);
      print(rows?[0]); // Imprimir los datos obtenidos
      print(rows?[1]); // Imprimir los datos obtenidos
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false; // Cambiar el estado de carga en caso de error
      });
    }
  }
  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('Home'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [   
            ElevatedButton(
              child: const Text('notification'),
              onPressed: () async {
                await Flushbar(
                  title: 'Hey Ninja',
                  message:
                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
                  duration: const Duration(seconds: 3),
                ).show(context);
              },
            ),          
          ],
        ),
      ),
      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
    );
  }
}