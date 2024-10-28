// ignore_for_file: file_names, unused_import, avoid_print
import 'package:flutter/material.dart';
import 'package:login/global/gsheet.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:login/global/hive.dart';
import 'package:login/model/community.dart';
import 'package:login/model/model.dart';
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
  late Offset fabOffset; // Offset para la posición del FAB

  @override
  void initState() {
    super.initState();
    // Inicializa la posición del FAB en la parte inferior derecha
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        fabOffset = Offset(
          MediaQuery.of(context).size.width - 70, // Ancho de la pantalla menos el tamaño del FAB
          MediaQuery.of(context).size.height - 120, // Alto de la pantalla menos espacio para el FAB
        );
      });
    });    
    loadData();
    // loadNotes();
  }
  
  Future<List<Community>> getCommunity() async{
      await DatabaseHelper().initialize();
      final dbHelper = DatabaseHelper();
      return dbHelper.get();
  }

  void loadNotes() async {
    await DatabaseHelper().initialize();
    final dbHelper = DatabaseHelper();
    // await dbHelper.add('furion1', 2024);
    // await dbHelper.add('furion2', 2024);
    // await dbHelper.add('furion3', 2024);
    // await dbHelper.add('furion4', 2024);
    // await dbHelper.update(4, 'master', 2024);
    // await dbHelper.delete(2);
    var records = dbHelper.get(); // Asegúrate de que este método esté implementado
    for (var product in records) {
      print('name: ${product.name}, lname: ${product.lname}');
    }
    // await dbHelper.exportHiveDatabase();
    // await dbHelper.exportDatabaseJSON();
  }

  @override
  void dispose() {
    // DatabaseHelper().close(); // Cierra la tienda al salir
    super.dispose();
  }

  Future<void> loadData() async {
    // DatabaseHelper().clearAllData();
    await loadGsheetData();
  }

  Future<String> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Formatear la fecha como 'dd/MM/yyyy' o el formato que prefieras
      String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      return formattedDate; // Establece la fecha en el controlador
    }
    return '';
  }

  Future<void> modalAdd(BuildContext context) async {
    String title = 'Add Data';
    String content = 'Data successfully add';
    dynamic color = Colors.green;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lnameController = TextEditingController();
    final TextEditingController ciController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController birthdateController = TextEditingController();
    final TextEditingController ageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nombre',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lnameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Apellido',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ciController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Cédula de Identidad',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Teléfono',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Dirección',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Correo Electrónico',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: birthdateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Fecha de Nacimiento',
                  ),
                  readOnly: true, // Hace que el campo sea solo lectura
                  onTap: () async {
                      String? date = await _selectDate(context);
                      if (date.isNotEmpty) {
                        birthdateController.text = date; // Actualiza el controlador con la fecha seleccionada
                      }
                  }, // Muestra el calendario al tocar el campo                  
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Edad',
                  ),
                  keyboardType: TextInputType.number,
                ),             
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Aceptar'),
              onPressed: () {
                  List<dynamic> addData = [
                    nameController.text,
                    lnameController.text,
                    ciController.text,
                    phoneController.text,
                    emailController.text,
                    addressController.text,
                    birthdateController.text,
                    int.tryParse(ageController.text) ?? 0, // Asegúrate de convertir edad a int
                  ];                
                  addHide(addData);
                _showToast(context, content, color);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> modal(BuildContext context, form, rows, index) async {
    String title = 'Delete Data';
    String content = 'Data successfully deleted';
    dynamic color = Colors.red;
    if (form == 0) {
      title = 'Edit Data';
      content = 'Data successfully edit';
      color = Colors.green;
    } else if (form == 3) {
      title = 'Add Data';
      content = 'Data successfully add';
      color = Colors.green;    
      print(233);
    }

    final TextEditingController nameController = TextEditingController();
    final TextEditingController lnameController = TextEditingController();
    final TextEditingController ciController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController birthdateController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    int ids = 0;
    if (rows.isNotEmpty) {
      ids = rows[0];
      nameController.value = rows[1];
      lnameController.value = rows[2];
      ciController.value = rows[3];
      phoneController.value = rows[4];
      emailController.value = rows[5];
      addressController.value = rows[6];
      birthdateController.value = rows[7];
      ageController.value = rows[8].toString() as TextEditingValue;
    }
    print(title);
    print(content);
    print(color);
    print(rows);
    print(ids);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            children: [
                Text(
                  'id: $ids \n'
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nombre',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lnameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Apellido',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ciController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Cédula de Identidad',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Teléfono',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Dirección',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Correo Electrónico',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: birthdateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Fecha de Nacimiento',
                  ),
                  readOnly: true, // Hace que el campo sea solo lectura
                  onTap: () async {
                      String? date = await _selectDate(context);
                      if (date.isNotEmpty) {
                        birthdateController.text = date; // Actualiza el controlador con la fecha seleccionada
                      }
                  }, // Muestra el calendario al tocar el campo                  
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Edad',
                  ),
                  keyboardType: TextInputType.number,
                ),             
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Aceptar'),
              onPressed: () {
                if (form == 1) {           
                  List<List<dynamic>> rowss= [rows];
                  removeData(rowss);
                  revomeHide(ids, index);
                } else if (form == 0) {
                  List<dynamic> updateData = [
                    ids,
                    nameController.text,
                    lnameController.text,
                    ciController.text,
                    phoneController.text,
                    emailController.text,
                    addressController.text,
                    birthdateController.text,
                    int.tryParse(ageController.text) ?? 0, // Asegúrate de convertir edad a int
                  ];
                  updateHide(updateData, index);
                } else {
                  List<dynamic> addData = [
                    nameController.text,
                    lnameController.text,
                    ciController.text,
                    phoneController.text,
                    emailController.text,
                    addressController.text,
                    birthdateController.text,
                    int.tryParse(ageController.text) ?? 0, // Asegúrate de convertir edad a int
                  ];
                  addHide(addData);                
                }
                _showToast(context, content, color);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  addHide(add) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initialize();
    await dbHelper.insert(add);
    loadGsheetData();
  }

  updateHide(rows, index) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initialize();
    await dbHelper.update(rows, index);
    loadGsheetData();
  }  

  revomeHide(ids, index) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initialize();
    await dbHelper.delete(ids, index);
    loadGsheetData();
  }

  void removeData(List<List<dynamic>> row) {
    setState(() {
      filter.remove(row);
    });
  }

  Future<void> loadGsheetData() async {
    try {
      var fetchedRows = await Gsheet.dataSheet(); // Esperar a que se complete
      List<Community> rs = DatabaseHelper().get(); // Esperar a que se complete y obtener una lista de `Community`
      // Convertimos `rs` a una lista de listas dinámicas (o mapas) para que sea compatible
      List<List<dynamic>> rsAsList = rs.map((community) => [
        community.id,
        community.name,
        community.lname,
        community.ci,
        community.phone,
        community.email,
        community.address,
        community.birthdate,
        community.age,
      ]).toList();      
      setState(() {
        var rs = fetchedRows.cast<List<dynamic>>(); // Actualizar el estado con los datos
        // Inicializar data si está nulo
        data ??= [];
        heads = rs;
        // Evitar duplicación de datos si se vuelve a llamar loadGsheetData
        data!.clear();
        filter = rsAsList; // Asignamos la lista procesada a `filter`
        data = rsAsList;
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
  // Método para manejar el movimiento del FAB
  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      fabOffset += details.delta; // Actualiza la posición del FAB

      // Limitar el movimiento del FAB dentro de los bordes de la pantalla
      fabOffset = Offset(
        fabOffset.dx.clamp(0, MediaQuery.of(context).size.width - 57), // Limitar a la izquierda y derecha
        fabOffset.dy.clamp(0, MediaQuery.of(context).size.height - 112), // Limitar a arriba y abajo
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
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
                          },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            clearText();
                          });
                        },
                      ),
                    ),
                    methodInteractiveViewer(context),
                  ],
                ),
                methodPositioned(),
              ]
            ),
      );
  }

  Container methodInteractiveViewer(BuildContext context) {
    return 
      Container(
        alignment: Alignment.center,
          child:  InteractiveViewer(
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child
                : head.isEmpty
                ? const Text('No data')
                : DataTable(
                  columns: [
                    const DataColumn(label: Text('ID')),
                    DataColumn(label: Text(head.isNotEmpty ? head[0] : '')),
                    DataColumn(label: Text(head.length > 1 ? head[1] : '')),
                    DataColumn(label: Text(head.length > 2 ? head[2] : '')),
                    DataColumn(label: Text(head.length > 3 ? head[3] : '')),
                    DataColumn(label: Text(head.length > 4 ? head[4] : '')),
                    DataColumn(label: Text(head.length > 5 ? head[5] : '')),
                    DataColumn(label: Text(head.length > 6 ? head[6] : '')),
                    DataColumn(label: Text(head.length > 7 ? head[7] : '')),
                    const DataColumn(label: Text('Action')),
                  ],
                  rows: filter.isNotEmpty
                      ? filter.asMap().entries.map((entry) {
                        final indexz = entry.key; // Obtiene el índice de la entrada
                        final row = entry.value; // Obtiene la fila correspondiente                        
                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                // Cambiar el color de fondo de las filas seleccionadas
                                if (states.contains(WidgetState.selected)) {
                                  return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                                }
          
                                // Alternar entre colores para filas no seleccionadas
                                final index = filter.indexOf(row);
                                return index.isEven ? Colors.white : Colors.grey.withOpacity(0.1);
                              },
                            ),
                            cells: List<DataCell>.generate(10, (index) {
                              if (index < row.length) {
                                return DataCell(Text(row[index].toString()));
                              } else if (index == 9) {
                                // Columna de acción
                                return DataCell(
                                  Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        tooltip: 'Edit Row',
                                        onPressed: () {
                                          setState(() {
                                            // Llama al modal de edición aquí
                                            modal(context, 0, row, indexz);
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        tooltip: 'Delete Row',
                                        onPressed: () {
                                          setState(() {
                                            modal(context, 1, row, indexz);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return const DataCell(Text(''));
                              }
                            }),
                          );
                        }).toList()
                      : [],
                ),
            ),
          ),
      );
  }

  Positioned methodPositioned() {
    return Positioned(
      left: fabOffset.dx,
      top: fabOffset.dy,
      child: GestureDetector(
        onPanUpdate: _onDragUpdate, // Maneja el movimiento
        child: FloatingActionButton(
          onPressed: () {
            // modalAdd(context); 
            modal(context, 3, [], 0);
          },             
          tooltip: 'Agregar Registro',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showToast(BuildContext context, content, color) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(content),
        backgroundColor: color,
        // action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }  
}