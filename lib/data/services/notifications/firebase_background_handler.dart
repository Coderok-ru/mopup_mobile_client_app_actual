import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Обработчик фоновых сообщений Firebase Cloud Messaging.
/// Должен быть top-level функцией.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Фоновое сообщение получено: ${message.messageId}');
  print('📱 Заголовок: ${message.notification?.title}');
  print('📱 Текст: ${message.notification?.body}');
  print('📱 Данные: ${message.data}');
  // В фоновом режиме Android автоматически показывает уведомление,
  // если в сообщении есть поле notification
  // Если нужно показать уведомление из data, используем flutter_local_notifications
  if (message.notification == null && message.data.isNotEmpty) {
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);
    await localNotifications.initialize(initializationSettings);
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'order_created_channel',
        'Создание заказов',
        description: 'Уведомления о создании заказов',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      );
      await androidImplementation.createNotificationChannel(channel);
    }
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'order_created_channel',
      'Создание заказов',
      channelDescription: 'Уведомления о создании заказов',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@drawable/ic_stat_name',
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);
    await localNotifications.show(
      message.hashCode,
      message.data['title'] ?? 'Новое уведомление',
      message.data['body'] ?? message.data['message'] ?? '',
      notificationDetails,
    );
    print('✅ Фоновое уведомление из data показано');
  } else if (message.notification != null) {
    print('✅ Фоновое уведомление будет показано системой автоматически');
  }
}

