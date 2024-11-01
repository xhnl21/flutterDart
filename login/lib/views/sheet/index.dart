// ignore_for_file: file_names, unused_import, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login/global/gsheet.dart';
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
  }
  
  Future<List<Community>> getCommunity() async{
      await DatabaseHelper().initialize();
      final dbHelper = DatabaseHelper();
      return dbHelper.get();
  }

  @override
  void dispose() {
    super.dispose();
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
    }

    final TextEditingController nameController = TextEditingController();
    final TextEditingController lnameController = TextEditingController();
    final TextEditingController ciController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController birthdateController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    int ids = 0;
    if (rows.isNotEmpty) {
      ids = rows[0];
      nameController.text = rows[1].toString();
      lnameController.text = rows[2].toString();
      ciController.text = rows[3].toString();
      phoneController.text = rows[4].toString();
      emailController.text = rows[5].toString();
      addressController.text = rows[6].toString();
      birthdateController.text = rows[7].toString();
      ageController.text = rows[8].toString();
    }
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content
            : form == 1
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Esta seguro que desea eliminar este dato?')
                ]
              )
            : Form(
              key: formKey,
              child: 
                formValidation(
                  nameController, lnameController, ciController, phoneController, 
                  addressController, emailController, birthdateController, ageController, context
                ),
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
            FilledButton(
              style
              : form == 1
              ? ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.red.withOpacity(0.7);
                      }
                      return Colors.red;
                    },
                  ),
                )
              : ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.green.withOpacity(0.7);
                      }
                      return Colors.green;
                    },
                  ),
                ),
              onPressed: (){
                if (formKey.currentState!.validate()) {
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
                } 
              },
              child: const Text('Aceptar')
            ),
          ],
        );
      },
    );
  }

  Column formValidation(
      TextEditingController nameController, TextEditingController lnameController, TextEditingController ciController, 
      TextEditingController phoneController, TextEditingController addressController, TextEditingController emailController, 
      TextEditingController birthdateController, TextEditingController ageController, BuildContext context
    ) {
    return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    buildTextField('Nombre', nameController, 'Por favor, ingrese un nombre.'),
                    buildTextField('Apellido', lnameController, 'Por favor, ingrese un apellido.'),
                    buildTextFieldNumber('Cédula de Identidad', ciController, 'Por favor, ingrese una CI.'),
                    buildTextFieldNumber('Teléfono', phoneController, 'Por favor, ingrese una teléfono.'),
                    buildTextField('Dirección', addressController, 'Por favor, ingrese una dirección.'),
                    buildTextFieldEmail('Correo Electrónico', emailController, 'Por favor, ingrese un Correo.'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child:  TextFormField(
                        controller: birthdateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Fecha de Nacimiento.',
                          isDense: true,
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                        readOnly: true, // Hace que el campo sea solo lectura
                        onTap: () async {
                            String? date = await _selectDate(context);
                            if (date.isNotEmpty) {
                              birthdateController.text = date;
                            }
                        }, 
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese una Fecha.';
                          }
                          return null;
                        },
                      ),
                    ),
                    buildTextFieldNumber('Edad', ageController, 'Por favor, ingrese una edad.'),
                ],
              );
  }

  Future<void> loadData() async {
    // DatabaseHelper().clearAllData();
    await loadGsheetData();
  }

  addHide(add) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initialize();
    await dbHelper.insert(add);
    await Gsheet.insertSheet(add, filter.length + 2);
    loadGsheetData();
  }

  updateHide(rows, index) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initialize();
    await dbHelper.update(rows, index);
    await Gsheet.updateSheet(rows, index + 2);
    loadGsheetData();
  }  

  revomeHide(ids, index) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initialize();
    await dbHelper.delete(ids, index);
    await Gsheet.deleteSheet(index + 2);
    loadGsheetData();
  }

  void removeData(List<List<dynamic>> row) {
    setState(() {
      filter.remove(row);
    });
  }

  Future<void> loadGsheetData() async {
    try {
      var fetchedRows = await Gsheet.readSheet(); // Esperar a que se complete
      await DatabaseHelper().initialize();
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
          ? circularProgressIndicator()
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

  Center circularProgressIndicator() => const Center(child: CircularProgressIndicator());

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


  Widget buildTextField(String hint, TextEditingController controller, String errorMsg, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: 
          TextFormField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            hintText: hint,
            contentPadding: const EdgeInsets.all(8.0),
          ),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return errorMsg;
            }        
            return null;
          },
        ),
    );
  }

  Widget buildTextFieldEmail(String hint, TextEditingController controller, String errorMsg, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: 
          TextFormField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            hintText: hint,
            contentPadding: const EdgeInsets.all(8.0),
          ),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return errorMsg;
            }
            final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Por favor, ingrese un correo válido.';
            }            
            return null;
          },
        ),
    );
  }

  Widget buildTextFieldNumber(String hintText, TextEditingController controller, String validationMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
          isDense: true,
          contentPadding: const EdgeInsets.all(8.0),
        ),
        keyboardType: TextInputType.number, // Teclado numérico
        inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Permitir solo dígitos
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          return null;
        },
      )
    );
  }
}