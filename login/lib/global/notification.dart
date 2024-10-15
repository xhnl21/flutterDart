import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
    static final notification = FlutterLocalNotificationsPlugin();

    static init() {
      const InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );    
      notification.initialize(initializationSettings);
    }

    static pushNotification(title, body) async {
      int id = 100;
      var androidDetails = const AndroidNotificationDetails(
        'channelId', 
        'channelName',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true
      );
      var ioDetails = const DarwinNotificationDetails();
      var notificationDetails = NotificationDetails(android: androidDetails, iOS: ioDetails);
      await notification.show(id, title, body, notificationDetails);       
    }
}