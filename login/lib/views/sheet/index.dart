// ignore_for_file: file_names, unused_import, avoid_print
import 'package:flutter/material.dart';
import 'package:login/global/gsheet.dart';
// import 'package:sqflite/sqflite.dart';
class SheetScreen extends StatefulWidget {
  const SheetScreen({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.person_off, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  
  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  List<List<dynamic>>? data; // Para almacenar los datos
  bool isLoading = true; // Para mostrar el estado de carga
  List<String> head = [];
  List<List<dynamic>>? heads; // Para almacenar los datos
  List<List<dynamic>> filter = []; // Cambiar a lista de listas dinámicas

  @override
  void initState() {
    super.initState();
    loadData();
  }
  Future<void> loadData() async {
    await loadGsheetData();
    await demoSqflite();
  }
  Future<void> demoSqflite() async {
    // try {
    //   Database db = await Gsheet.initDB();    
    //   await Gsheet.insertUser(db, 'John Doe', 25);
    //   await Gsheet.insertUser(db, 'Jane Doe', 30);
    //   await Gsheet.insertUser(db, 'Xavier H. Nunez L.', 37);

    //   var rs = await Gsheet.getUsers(db);
    //   print(rs);
    // } catch (e) {
    //   print('Error fetching data: $e');
    // }
  }

  Future<void> modal(BuildContext context, data, form, rows) async {
    // print(rows);
    // print(form);
    // print(data);
    // String title = 'Delete Data';
    // String content = 'Data successfully deleted';
    // dynamic color = Colors.red;
    // if (form == 0) {
    //   title = 'Edit Data';
    //   content = 'Data successfully edit';
    //   color = Colors.green;
    // }
    // final id = row;
    // final rsData = data.where((row) => row['id'] == id).toList();
    // final rs = rsData[0];
    // final ids = rs["id"];
    // final name = rs["name"];
    // final age = rs["age"];
    // final email = rs["email"];  
    // return showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text(title),
    //       content: Text(
    //         'id: $ids \n'
    //         'name: $name \n'
    //         'age: $age \n'
    //         'email: $email \n',
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           style: TextButton.styleFrom(
    //             textStyle: Theme.of(context).textTheme.labelLarge,
    //           ),
    //           child: const Text('Cancelar'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //         TextButton(
    //           style: TextButton.styleFrom(
    //             textStyle: Theme.of(context).textTheme.labelLarge,
    //           ),
    //           child: const Text('Aceptar'),
    //           onPressed: () {
    //             if (form == 1) {
    //               removeData(rows);
    //             }
    //             // _showToast(context, content, color);
    //             // Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  void removeData(List<List<dynamic>> row) {
    setState(() {
      filter.remove(row);
    });
  }

  Future<void> loadGsheetData() async {
    try {
      var fetchedRows = await Gsheet.dataSheet(); // Esperar a que se complete
      setState(() {
        var rs = fetchedRows.cast<List<dynamic>>(); // Actualizar el estado con los datos
        // Inicializar data si está nulo
        data ??= [];
        heads = rs;
        // Evitar duplicación de datos si se vuelve a llamar loadGsheetData
        data!.clear();

        // Añadir las filas excluyendo el encabezado (índice 0)
        for (var i = 1; i < rs.length; i++) {
          data?.add(rs[i]);
        }

        filter = List.from(data!); // Inicialmente, todos los datos son visibles
        isLoading = false; // Cambiar el estado de carga
      });

      // Asignar encabezados
      if (heads != null && heads!.isNotEmpty) {
        head = heads![0].cast<String>(); // Obtener encabezados
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false; // Cambiar el estado de carga en caso de error
      });
    }
  }

  final fieldText = TextEditingController();

  void clearText() {
    setState(() {
      fieldText.clear();
      filter = data ?? []; // Resetear filtro a los datos originales
    });
  }

  void filterData(String query) {
    if (query.isEmpty) {
      filter = data ?? [];
    } else {
      setState(() {
        filter = data!.where((row) {
          return row.any((cell) => cell.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar indicador de carga
          : ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.search),
            title: TextField(
                controller: fieldText,
                decoration: const InputDecoration(
                hintText: 'Search', border: InputBorder.none),
                onChanged: (value) {
                  setState(() {
                    filterData(value);
                  });
                }),
            trailing: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  clearText();
                });
              },
            ),
          ),
          InteractiveViewer(
            child: FittedBox(
              child:head.isEmpty
                ? const Text('No data')
                : DataTable(
                    // columns: head.map((column) => DataColumn(label: Text(column))).toList(),
                    columns: [
                      DataColumn(label: Text(head[0])),
                      DataColumn(label: Text(head[1])),
                      DataColumn(label: Text(head[2])),
                      DataColumn(label: Text(head[3])),
                      DataColumn(label: Text(head[4])),
                      DataColumn(label: Text(head[5])),
                      const DataColumn(label: Text('Action')),
                    ],
                    rows: filter.isNotEmpty // Verifica si hay más de un elemento
                        ? filter.map((row) {
                            // print(row);
                            // var todo = row.map((cell) => DataCell(Text(cell.toString()))).toList();
                            return DataRow(
                              // cells: row.map((cell) => DataCell(Text(cell.toString()))).toList(),
                              cells: [
                                DataCell(Text(row[0])),
                                DataCell(Text(row[1])),
                                DataCell(Text(row[2])),
                                DataCell(Text(row[3])),
                                DataCell(Text(row[4])),
                                DataCell(Text(row[5])), 
                                DataCell(
                                    Row(
                                        children: <Widget>[
                                            IconButton(
                                                icon: const Icon(Icons.edit),
                                                tooltip: 'Edit Row',
                                                onPressed: () {
                                                    setState(() {
                                                        // modal(context, _data, row['id'], 0, row);
                                                    });
                                                },
                                            ),                                            
                                            IconButton(
                                                icon: const Icon(Icons.delete),
                                                tooltip: 'Delete Row',
                                                onPressed: () {
                                                    setState(() {
                                                        modal(context, filter, 1, row);
                                                    });
                                                },
                                            ),
                                        ],
                                     )
                                 ),
                              ]
                            );
                          }).toList()
                        : [], // Si no hay suficientes elementos, devuelve una lista vacía
                  ),
            ),
          ),
        ]
      ),
    );
  }
}