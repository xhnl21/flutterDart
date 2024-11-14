// ignore_for_file: file_names, unused_import, avoid_print
import 'package:flutter/material.dart';
import 'package:login/model/model.dart';
import 'package:login/model/offlines.dart';
class HistorySheetScreen extends StatefulWidget {
  const HistorySheetScreen({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.person_off, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  
  @override
  State<HistorySheetScreen> createState() => _HistorySheetScreenState();
}

class _HistorySheetScreenState extends State<HistorySheetScreen> {
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadData() async {
    // OfflinesAction().clearAllData();
    await loadGsheetData();
  }

  void removeData(List<List<dynamic>> row) {
    setState(() {
      filter.remove(row);
    });
  }

// Actualización en loadGsheetData
Future<void> loadGsheetData() async {
  try {
    final dbHelper = OfflinesAction();
    var offlineData = await dbHelper.get();
    List<List<dynamic>> rsAsList = offlineData.map((community) => [
      community.id,
      community.action,
      community.data,
      community.status.toString() == '0' ? 'No sincronizado' : 'Sincronizado',
      community.create_at,
      community.update_at,
    ]).toList();
    
    setState(() {
      List<List<dynamic>> rsHeader = [['id', 'action', 'data', 'status', 'create_at', 'update_at']];
      data = rsAsList;
      filter = rsAsList;
      heads = rsHeader;
      isLoading = false;
    });

    if (heads != null && heads!.isNotEmpty) {
      head = heads![0].cast<String>();
    }
    // dbHelper.closeAllBoxes();
  } catch (e) {
    print('Error fetching data: $e');
    setState(() {
      isLoading = false;
    });
  }
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
                    methodInteractiveViewer(context),
                  ],
                ),
              ]
            ),
    );
  }

  Center circularProgressIndicator() => const Center(child: CircularProgressIndicator());

Container methodInteractiveViewer(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    child: InteractiveViewer(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: head.isEmpty
            ? const Text('No data')
            : DataTable(
                columns: head.map((col) => DataColumn(label: Text(col))).toList(),
                rows: filter.map((row) {
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                        }
                        final index = filter.indexOf(row);
                        return index.isEven ? Colors.white : Colors.grey.withOpacity(0.1);
                      },
                    ),
                    cells: row.asMap().entries.map((entry) {
                      // int index = entry.key;
                      dynamic cell = entry.value;                     
                      return DataCell(Text(cell.toString()));
                    }).toList(),
                  );
                }).toList(),
              ),
      ),
    ),
  );
}
}