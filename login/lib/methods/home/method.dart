import 'package:dio/dio.dart';
class Methods {
  final String? url;
  Methods({
      this.url,
  });
  static Future get(String url) async {
    if (url != '') {
      final res = await Dio().get(url);
      return res.data;
    } else {
      return [];
    }
  }  

  static Future<int> getAllResques(String url) async {
    if (url != '') {
      final res = await Dio().get(url);
      return res.data['count']; 
    } else {
      return 0;
    }      
  }
}
