// ignore_for_file: avoid_print, unrelated_type_equality_checks

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:login/global/gsheet.dart';
import 'package:login/model/offline_action.dart';
import 'dart:convert';
class ConnectivityService {
  static connectionStatusServises(connectionStatus) {
    String value;
    int number;
    switch (connectionStatus) {
      case 'ConnectivityResult.wifi':
        value = 'Connected to WiFi';
        number = 4;
        break;
      case 'ConnectivityResult.mobile':
        value = 'Connected to Mobile Network';
        number = 3;
        break;
      case 'ConnectivityResult.ethernet':
        value = 'Connected to Red Network';
        number = 2;
        break;        
      case 'ConnectivityResult.none':
        value = 'No internet connection';
        number = 1;
        break;
      default:
        value = 'Unknown';
        number = 0;
        break;
    }
    // synccronizacion(number);
    return [{'msj': value, 'status': number}];
  }

  static Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    var status = connectivityResult[0];
    if (status == ConnectivityResult.mobile) {
      return true; // Hay conexión
    }  
    if (status == ConnectivityResult.wifi) {
      return true; // Hay conexión
    }
    if (status == ConnectivityResult.ethernet) {
      return true; // Hay conexión
    }
    return false; // Sin conexión
  }

  static synccronizacion(number) async {
    if (number == 4 || number == 3 || number == 2){
        final dbHelper = OfflineAction();
        // final dbHelpers = OfflineMaster();
        await dbHelper.clearAllData();
        var rs = await dbHelper.get();

        // Si necesitas dividir los datos en 'create', 'update' y 'delete', puedes hacerlo así:
        var create = [];
        var createBool = false;
        var update = [];
        var updateBool = false;
        var delete = [];
        
        for (var community in rs) {
          if(community.status == '0'){
            if (community.action == 'create') {
              create.add(community);
            } else if (community.action == 'update') {
              update.add(community);
            } else if (community.action == 'delete') {
              delete.add(community);
            }          
          }
        }
        
        // Imprimir los IDs de las acciones
        if (create.isNotEmpty) {
          for (var i = 0; i < create.length; i++) {
            var id = create[i].id - 1;
            String dataString = create[i].data;
            List<dynamic> dataArray = json.decode(dataString);
            await Gsheet.insertSheet(dataArray[1], dataArray[0]);
            
            create[i].status = '1';
            List<dynamic> dataToUpdate = [
              create[i].id,
              create[i].action,
              create[i].data,
              create[i].status,
              create[i].create_at,
              create[i].update_at,
            ];
            dbHelper.update(dataToUpdate, id);
            // dbHelpers.update(dataToUpdate, id);
          }
          createBool = true;
        } else {
          createBool = true;
        }
        if (createBool) {
          if (update.isNotEmpty) {
            // print('Update IDs: ${update.map((e) => e.id).toList()}');
            for (var i = 0; i < update.length; i++) {
              var id = update[i].id - 1;
              String dataString = update[i].data;
              List<dynamic> dataArray = json.decode(dataString);
              await Gsheet.updateSheet(dataArray[1], dataArray[0]);
              
              update[i].status = '1';
              List<dynamic> dataToUpdate = [
                update[i].id,
                update[i].action,
                update[i].data,
                update[i].status,
                update[i].create_at,
                update[i].update_at,
              ];
              dbHelper.update(dataToUpdate, id);
              // dbHelpers.update(dataToUpdate, id);
            }
            updateBool = true;
          } else {
            updateBool = true;
          }
          if (updateBool) {
            if (delete.isNotEmpty) {
              print('Delete IDs: ${delete.map((e) => e.id).toList()}');
              for (var i = 0; i < delete.length; i++) {
                var id = delete[i].id - 1;
                String dataString = delete[i].data;
                List<dynamic> dataArray = json.decode(dataString);
                await Gsheet.deleteSheet(dataArray[0]);
                
                delete[i].status = '1';
                List<dynamic> dataToUpdate = [
                  delete[i].id,
                  delete[i].action,
                  delete[i].data,
                  delete[i].status,
                  delete[i].create_at,
                  delete[i].update_at,
                ];
                dbHelper.update(dataToUpdate, id);
                // dbHelpers.update(dataToUpdate, id);
              }
            }
          }
        }     
    }
  }
}