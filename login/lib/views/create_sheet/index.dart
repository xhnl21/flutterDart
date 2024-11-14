// ignore_for_file: file_names, unused_import, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login/global/create_gsheets.dart';
import 'package:login/model/create_sheet.dart';
import 'package:login/model/model.dart';
// import 'package:login/model/offline_action.dart';
class CreateSheetScreen extends StatefulWidget {
  const CreateSheetScreen({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.person_off, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  
  @override
  State<CreateSheetScreen> createState() => _CreateSheetScreenState();
}

class _CreateSheetScreenState extends State<CreateSheetScreen> {
  List<List<dynamic>>? data; // Para almacenar los datos
  bool isLoading = true; // Para mostrar el estado de carga
  List<String> head = [];
  List<List<dynamic>>? heads; // Para almacenar los datos
  List<List<dynamic>> filter = []; // Cambiar a lista de listas dinámicas
  late Offset fabOffset; // Offset para la posición del FAB
  bool isCheckedPDF = false;
  bool isCheckedEXCEL = false;
  bool isCheckedBD = false;
  
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
  
  @override
  void dispose() {
    super.dispose();
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

    final TextEditingController ciController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController rolController = TextEditingController();
    final TextEditingController nameSheetController = TextEditingController();

    final TextEditingController expPDFController = TextEditingController();
    final TextEditingController expEXCELController = TextEditingController();
    final TextEditingController expDBController = TextEditingController();
    // final TextEditingController birthdateController = TextEditingController();
    // final TextEditingController ageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    int ids = 0;
    if (rows.isNotEmpty) {
      ids = rows[0];
      ciController.text = rows[3].toString();
      emailController.text = rows[5].toString();
      descriptionController.text = rows[1].toString();  
      rolController.text = rows[2].toString();
      nameSheetController.text = rows[4].toString();

      expPDFController.text = rows[6].toString();
      expEXCELController.text = rows[7].toString();
      expDBController.text = rows[8].toString();
    }
    return showDialog(
      context: context,
      builder: (BuildContext context, ) {
        return AlertDialog(
          title: Text(title),
          content
            : form == 1
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [   
                  Text('Esta seguro que desea eliminar este dato?'),                 
                ]
              )
            : Form(
              key: formKey,
              child: 
                formValidation(
                  ciController, emailController, descriptionController, rolController, 
                  nameSheetController, expPDFController, expEXCELController, expDBController, context
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
                if (form == 1) {
                    List<List<dynamic>> rowss= [rows];
                    removeData(rowss);
                    revomeHide(ids, index);
                } else {
                  if (formKey.currentState!.validate()) {
                    if (form == 0) {
                      List<dynamic> updateData = [
                        ids,
                        ciController.text,
                        emailController.text,
                        descriptionController.text,
                        rolController.text,
                        nameSheetController.text,
                        expPDFController.text,
                        expEXCELController.text,
                        expDBController.text,
                      ];
                      updateHide(updateData, index);
                    } else {
                      List<dynamic> addData = [
                        ciController.text,
                        emailController.text,
                        descriptionController.text,
                        rolController.text,
                        nameSheetController.text,
                        expPDFController.text,
                        expEXCELController.text,
                        expDBController.text,
                      ];
                      addHide(addData);                
                    }
                  }                
                }
                _showToast(context, content, color);
                Navigator.of(context).pop();                
              },
              child: const Text('Aceptar')
            ),
          ],
        );
      },
    );
  }

  Widget formValidation(
      TextEditingController ciController, TextEditingController emailController, TextEditingController descriptionController, 
      TextEditingController rolController, TextEditingController nameSheetController, TextEditingController expPDFController, 
      TextEditingController expEXCELController, TextEditingController expDBController, BuildContext context
    ) {
    return StatefulBuilder(builder: (context, setStateW) {
      return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    buildTextField('Cédula', ciController, 'Por favor, ingrese un cédula.'),
                    buildTextFieldEmail('Correo Electrónico', emailController, 'Por favor, ingrese un Correo.'),
                    buildTextField('Description', descriptionController, 'Por favor, ingrese un descripcion.'),
                    buildTextField('Rol', rolController, 'Por favor, ingrese un rol.'),
                    buildTextField('Nombre de la Hoja', nameSheetController, 'Por favor, ingrese un nombre de la Hoja.'),
                    // buildTextField('Exportar PDF', expPDFController, 'Por favor, ingrese una dirección.'),
                    // buildTextField('Exportar EXCEL', expDBController, 'Por favor, ingrese una dirección.'),
                    // buildTextField('Exportar BD', expDBController, 'Por favor, ingrese una dirección.'),
                    CheckboxListTile(
                      title: const Text('Exportar PDF'),
                      value: isCheckedPDF,
                      onChanged: (value) {
                        setStateW(() {
                          print(value);
                          isCheckedPDF = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Exportar EXCEL'),
                      value: isCheckedEXCEL,
                      onChanged: (value) {
                        setStateW(() {
                          print(value);
                          isCheckedEXCEL = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Exportar BD'),
                      value: isCheckedBD,
                      onChanged: (value) {
                        setStateW(() {
                          print(value);
                          isCheckedBD = value ?? false;
                        });
                      },
                    ),
                ],
              );
    },);
  }

  Future<void> loadData() async {
    // OfflineAction().clearAllData();
    // DatabaseHelper().clearAllData();
    await loadGsheetData();
  }

  addHide(add) async {
    final dbHelper = CreateSheets();
    await dbHelper.initialize();
    await dbHelper.insert(add);
    await GsheetCreate.insertSheet(add, filter.length + 2);
    loadGsheetData();
  }

  updateHide(rows, index) async {
    final dbHelper = CreateSheets();
    await dbHelper.initialize();
    await dbHelper.update(rows, index);
    await GsheetCreate.updateSheet(rows, index + 2);
    loadGsheetData();
  }  

  revomeHide(ids, index) async {
    final dbHelper = CreateSheets();
    await dbHelper.initialize();
    await dbHelper.delete(ids, index);
    await GsheetCreate.deleteSheet(index + 2);
    loadGsheetData();
  }

  void removeData(List<List<dynamic>> row) {
    setState(() {
      filter.remove(row);
    });
  }

  Future<void> loadGsheetData() async {
    try {
      var fetchedRows = await GsheetCreate.readSheet(); // Esperar a que se complete
      await CreateSheets().initialize();
      List<Createsheet> rs = await  CreateSheets().get();
      List<List<dynamic>> rsAsList = rs.map((community) => [
        community.id,
        community.cedula,
        community.email,
        community.description,
        community.rol,
        community.name_sheet,
        community.id_sheet,
        community.export_pdf,
        community.export_excel,
        community.export_db,
        // community.create_at,
        // community.update_at,
      ]).toList();  
      print(rsAsList);
      setState(() {
        var rs = fetchedRows.cast<List<dynamic>>(); // Actualizar el estado con los datos
        heads = rs;
        data ??= [];
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
                    DataColumn(label: Text(head.length > 8 ? head[8] : '')),
                    // const DataColumn(label: Text('Create')),
                    // const DataColumn(label: Text('Update')),
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
                            cells: List<DataCell>.generate(11, (index) {
                              if (index < row.length) {
                                return DataCell(Text(row[index].toString()));
                              } else if (index == 10) {
                                // Columna de acción
                                return DataCell(
                                  Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        tooltip: 'Edit Row',
                                        onPressed: () {
                                          setState(() {
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