// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// double _volume = 0.0;
class FullView extends StatefulWidget {
  const FullView({super.key});

  @override
  StateFullView createState() => StateFullView();
}

class StateFullView extends State<FullView> {
  final List<Map<String, dynamic>> _data = [
    {'id':1, 'order':1, 'name': 'John Doe', 'age': 30, 'email': 'john.doe@example.com'},
    {'id':2, 'order':2, 'name': 'Jane Smith', 'age': 25, 'email': 'jane.smith@example.com'},
    {'id':3, 'order':3, 'name': 'Bob Johnson', 'age': 40, 'email': 'bob.johnson@example.com'},
    {'id':4, 'order':4, 'name': 'Sarah Lee', 'age': 35, 'email': 'sarah.lee@example.com'},
  ];
  
  List<Map<String, dynamic>> filter = [];

  void removeData(Map<String, dynamic> row) {
    setState(() {
      _data.remove(row);
    });
  }

  Future<void> modal(BuildContext context, data, row, form, Map<String, dynamic> rows) {
    String title = 'Delete Data';
    String content = 'Data successfully deleted';
    dynamic color = Colors.red;
    if (form == 0) {
      title = 'Edit Data';
      content = 'Data successfully edit';
      color = Colors.green;
    }
    final id = row;
    final rsData = data.where((row) => row['id'] == id).toList();
    final rs = rsData[0];
    final ids = rs["id"];
    final name = rs["name"];
    final age = rs["age"];
    final email = rs["email"];  
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            'id: $ids \n'
            'name: $name \n'
            'age: $age \n'
            'email: $email \n',
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
                  removeData(rows);
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

  void upDown(int index, bool isUp) {
    setState(() {
      if (isUp && index > 0) {
        // Mover el registro hacia arriba
        Map<String, dynamic> temp = _data[index - 1];
        _data[index - 1] = _data[index];
        _data[index] = temp;
      } else {
        // Mover el registro hacia abajo
        Map<String, dynamic> temp = _data[index + 1];
        _data[index + 1] = _data[index];
        _data[index] = temp;
      }
    });
  }

  void filterData(String index) {
    setState(() {
      if (index.length > 2) {
        filter = _data.where((item) {
          final name = item['name'].toString().toLowerCase();
          final email = item['email'].toString().toLowerCase();
          return name.contains(index.toLowerCase()) || email.contains(index.toLowerCase());
        }).toList();
      } else {
        filter = _data;
      }
    });
  } 

  final fieldText = TextEditingController();

  void clearText() {
    setState(() {
      fieldText.clear();
      filter = _data;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (filter.isEmpty) {
      filter = _data;
    }
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('User'),
      // ),      
      body: 
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
              child: DataTable(
                  headingRowColor:WidgetStateColor.resolveWith((states) => Colors.green), 
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.blue.withOpacity(0.1);
                    } else if (states.contains(WidgetState.selected)) {
                      return Colors.blue.withOpacity(0.3);
                    } else {
                      return null;
                    }
                  }), 
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Age')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Up')),
                    DataColumn(label: Text('Down')),
                    DataColumn(label: Text('Actions')),
                  ],            
                  rows:                        
                      filter.asMap().entries.map((entry) {
                        final index = entry.key;
                        final row = entry.value;
                        final id = row["id"];
                        return DataRow(
                            // onSelectChanged: (value) {
                            //   setState(() {});
                            // },
                            onLongPress: () {
                                setState(() {});
                            },
                            cells: [                                
                                DataCell(Text(row['name'])),
                                DataCell(Text(row['age'].toString())),
                                DataCell(Text(row['email'])),
                                if (index == 0)
                                  const DataCell(Text(''))
                                else 
                                  DataCell(
                                    index != 0
                                      ? IconButton(
                                          icon: const Icon(Icons.arrow_upward),
                                          tooltip: 'Up',
                                          onPressed: () {
                                            upDown(_data.indexOf(row), true);
                                          },
                                        )
                                      : const Text(''),
                                  ),
                                if(_data.indexOf(row) == (_data.length - 1))
                                  const DataCell(Text(''))
                                else
                                  DataCell(
                                    _data.indexOf(row) != _data.length - 1
                                      ? IconButton(
                                          icon: const Icon(Icons.arrow_downward),
                                          tooltip: 'Down',
                                          onPressed: () {
                                            upDown(_data.indexOf(row), false);
                                          },
                                        )
                                      : const Text(''),
                                  ),                              
                                DataCell(
                                    Row(
                                        children: <Widget>[
                                            IconButton(
                                                icon: const Icon(Icons.abc),
                                                tooltip: 'Details',
                                                onPressed: () {
                                                    setState(() {
                                                        context.go('/FullDetail/$id');
                                                        // context.push('/FullDetail/$id');
                                                        // modal(context, _data, row['id'], 0, row);
                                                    });
                                                },
                                            ),
                                            IconButton(
                                                icon: const Icon(Icons.edit),
                                                tooltip: 'Edit Row',
                                                onPressed: () {
                                                    setState(() {
                                                        modal(context, _data, row['id'], 0, row);
                                                    });
                                                },
                                            ),                                            
                                            IconButton(
                                                icon: const Icon(Icons.delete),
                                                tooltip: 'Delete Row',
                                                onPressed: () {
                                                    setState(() {
                                                        modal(context, _data, row['id'], 1, row);
                                                    });
                                                },
                                            ),
                                        ],
                                     )
                                 ),
                             ],
                         );
                      }).toList(),
              ),
            ),
          ),
        ]
      ),
      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
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