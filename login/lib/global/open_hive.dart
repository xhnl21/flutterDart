import 'package:hive/hive.dart';
import 'package:login/model/model.dart';

class OpenHive {
  static init() async {
    // Registra los adaptadores
    Hive.registerAdapter(CommunityAdapter());
    Hive.registerAdapter(OfflineAdapter());
    Hive.registerAdapter(OfflinesAdapter());
    Hive.registerAdapter(CreatesheetAdapter());

    // Abre las cajas
    await Hive.openBox<Community>("community");
    await Hive.openBox<Offline>("offline");
    await Hive.openBox<Offlines>("offlines"); 
    await Hive.openBox<Createsheet>("createsheet");
  }
}