import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'data/services/notifications/firebase_background_handler.dart';
import 'data/services/notifications/notification_service.dart';
import 'data/services/permissions/permissions_service.dart';
import 'presentation/views/app/app_view.dart';

/// Точка входа в приложение.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await GetStorage.init();
  final NotificationService notificationService = NotificationService();
  // Сначала инициализируем сервис (создаем каналы, но не запрашиваем разрешения)
  await notificationService.executeInit();
  // Затем запрашиваем разрешения на уведомления сразу при запуске приложения
  print('🔔 Запрос разрешений на уведомления при запуске приложения...');
  await notificationService.executeRequestPermissions();
  // Получаем FCM токен только после запроса разрешений
  final String? fcmToken = await notificationService.executeGetFCMToken();
  if (fcmToken != null) {
    print('🔑 FCM Token для отправки уведомлений:');
    print('🔑 $fcmToken');
  }
  final RemoteMessage? initialMessage =
      await notificationService.executeGetInitialMessage();
  if (initialMessage != null) {
    print('📱 Приложение открыто из уведомления: ${initialMessage.messageId}');
    print('📱 Данные уведомления: ${initialMessage.data}');
  }
  final PermissionsService permissionsService = PermissionsService();
  await permissionsService.executeRequestAllPermissions();
  Get.put<NotificationService>(notificationService, permanent: true);
  runApp(const App());
  // Обрабатываем навигацию после запуска приложения
  if (initialMessage != null) {
    // Ждем, пока GetX будет готов к навигации
    Future.delayed(const Duration(milliseconds: 1000), () {
      notificationService.executeHandleNotificationNavigation(
        initialMessage.data,
      );
    });
  }
}
