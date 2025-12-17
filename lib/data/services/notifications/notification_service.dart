import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/app_routes.dart';

/// Сервис для работы с локальными и push-уведомлениями.
class NotificationService {
  static const String _orderCreatedChannelId = 'order_created_channel';
  static const String _orderCreatedChannelName = 'Создание заказов';
  static const String _orderCreatedChannelDescription =
      'Уведомления о создании заказов';
  static const String _errorChannelId = 'error_channel';
  static const String _errorChannelName = 'Ошибки';
  static const String _errorChannelDescription = 'Уведомления об ошибках';

  /// Плагин локальных уведомлений.
  final FlutterLocalNotificationsPlugin plugin;

  /// Экземпляр Firebase Messaging.
  final FirebaseMessaging firebaseMessaging;

  /// Признак инициализации сервиса.
  bool isInitialized = false;

  /// Токен FCM.
  String? fcmToken;

  /// Создает сервис уведомлений.
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    FirebaseMessaging? messaging,
  })  : plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        firebaseMessaging = messaging ?? FirebaseMessaging.instance;

  /// Инициализирует плагин локальных уведомлений и Firebase Messaging.
  Future<void> executeInit() async {
    if (isInitialized) {
      return;
    }
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
    await _executeCreateNotificationChannels();
    await _executeSetupFirebaseMessaging();
    isInitialized = true;
  }

  /// Создает каналы уведомлений для Android.
  Future<void> _executeCreateNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
        _orderCreatedChannelId,
        _orderCreatedChannelName,
        description: _orderCreatedChannelDescription,
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );
      const AndroidNotificationChannel errorChannel = AndroidNotificationChannel(
        _errorChannelId,
        _errorChannelName,
        description: _errorChannelDescription,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );
      await androidImplementation.createNotificationChannel(orderChannel);
      await androidImplementation.createNotificationChannel(errorChannel);
      print('✅ Каналы уведомлений созданы: $_orderCreatedChannelId, $_errorChannelId');
    } else {
      print('⚠️ Android implementation не найдена');
    }
  }

  /// Настраивает Firebase Cloud Messaging.
  Future<void> _executeSetupFirebaseMessaging() async {
    print('🔧 Настройка Firebase Messaging...');
    await _executeGetFCMToken();
    _executeSetupMessageHandlers();
    firebaseMessaging.onTokenRefresh.listen((String newToken) {
      fcmToken = newToken;
      print('🔄 FCM Token обновлен: ${newToken.substring(0, newToken.length > 20 ? 20 : newToken.length)}...');
    });
    print('✅ Firebase Messaging настроен');
  }

  /// Запрашивает разрешения для Firebase Messaging.
  Future<void> _executeRequestFirebasePermissions() async {
    print('🔐 Запрос разрешений Firebase Messaging...');
    final NotificationSettings settings =
        await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('📱 Firebase разрешение: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Разрешение Firebase предоставлено');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('⚠️ Разрешение Firebase отклонено пользователем');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Временное разрешение Firebase');
    }
  }

  /// Получает FCM токен.
  Future<void> _executeGetFCMToken() async {
    try {
      // На iOS необходимо сначала получить APNS токен перед получением FCM токена
      if (Platform.isIOS) {
        print('🍎 Запрашиваю APNS токен для iOS...');
        final String? apnsToken = await firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          print('✅ APNS токен получен: ${apnsToken.substring(0, apnsToken.length > 20 ? 20 : apnsToken.length)}...');
        } else {
          print('⚠️ APNS токен не получен (может потребоваться время для регистрации)');
          // Ждем немного и пробуем еще раз
          await Future.delayed(const Duration(seconds: 2));
          final String? apnsTokenRetry = await firebaseMessaging.getAPNSToken();
          if (apnsTokenRetry == null) {
            print('⚠️ APNS токен все еще не доступен');
            print('💡 Убедитесь, что:');
            print('   1. Устройство подключено к интернету');
            print('   2. Push Notifications включены в Capabilities проекта');
            print('   3. Приложение имеет правильный provisioning profile с Push Notifications');
          }
        }
      }
      
      fcmToken = await firebaseMessaging.getToken();
      if (fcmToken != null) {
        print('🔑 FCM Token получен: ${fcmToken!.substring(0, fcmToken!.length > 20 ? 20 : fcmToken!.length)}...');
      } else {
        print('⚠️ FCM Token не получен (null)');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'apns-token-not-set') {
        print('⚠️ APNS токен не установлен');
        print('💡 Проверьте настройки:');
        print('   1. В Xcode: Signing & Capabilities → Push Notifications включены');
        print('   2. App ID в Apple Developer Portal имеет Push Notifications capability');
        print('   3. Provisioning profile включает Push Notifications');
        print('   4. Устройство подключено к интернету');
      } else {
        print('❌ Ошибка при получении FCM токена: ${e.code} - ${e.message}');
      }
      fcmToken = null;
    } catch (e) {
      print('❌ Неожиданная ошибка при получении FCM токена: $e');
      fcmToken = null;
    }
  }

  /// Настраивает обработчики сообщений FCM.
  void _executeSetupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);
  }

  /// Обрабатывает сообщение, полученное когда приложение на переднем плане.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 Получено сообщение в foreground: ${message.messageId}');
    print('📱 Заголовок: ${message.notification?.title}');
    print('📱 Текст: ${message.notification?.body}');
    print('📱 Данные: ${message.data}');
    if (message.notification != null) {
      await executeShowNotificationFromRemoteMessage(message);
    } else if (message.data.isNotEmpty) {
      // Если нет notification, но есть data, показываем уведомление из data
      await executeShowDataNotification(message);
    }
  }

  /// Обрабатывает нажатие на уведомление из фона.
  void _handleBackgroundMessageTap(RemoteMessage message) {
    executeHandleNotificationNavigation(message.data);
  }

  /// Обрабатывает нажатие на уведомление.
  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        // Пытаемся распарсить payload как JSON
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        executeHandleNotificationNavigation(data);
      } catch (e) {
        // Если payload не JSON, пытаемся распарсить как строку данных
        print('⚠️ Ошибка парсинга payload: $e');
        // Можно попробовать другой формат парсинга
      }
    }
  }

  /// Обрабатывает навигацию на основе данных из уведомления.
  void executeHandleNotificationNavigation(Map<String, dynamic> data) {
    print('🔔 Обработка навигации из уведомления: $data');
    // Определяем тип уведомления из данных
    final String? type = data['type'] as String?;
    final String? screen = data['screen'] as String?;
    // Если указан экран напрямую
    if (screen != null) {
      _navigateToScreen(screen, data);
      return;
    }
    // Если указан тип уведомления
    if (type != null) {
      switch (type.toLowerCase()) {
        case 'order':
        case 'order_status':
        case 'order_created':
        case 'order_updated':
          final String? orderId = data['order_id'] as String?;
          if (orderId != null) {
            _navigateToOrderDetails(orderId, data);
          } else {
            _navigateToOrders();
          }
          break;
        case 'payment':
          _navigateToPayment();
          break;
        case 'settings':
          _navigateToSettings();
          break;
        default:
          // По умолчанию открываем главный экран
          _navigateToMain();
          break;
      }
    } else {
      // Если тип не указан, проверяем наличие order_id
      final String? orderId = data['order_id'] as String?;
      if (orderId != null) {
        _navigateToOrderDetails(orderId, data);
      } else {
        _navigateToMain();
      }
    }
  }

  /// Навигация на экран деталей заказа.
  void _navigateToOrderDetails(String orderId, Map<String, dynamic> data) {
    print('📱 Навигация на детали заказа: $orderId');
    // Переходим на экран заказов, передавая order_id для дальнейшей навигации
    // Или можно сразу перейти на orderDetails, если есть полный объект заказа
    Get.toNamed(
      AppRoutes.orders,
      arguments: <String, dynamic>{'order_id': orderId, 'open_details': true},
    );
  }

  /// Навигация на экран заказов.
  void _navigateToOrders() {
    print('📱 Навигация на экран заказов');
    Get.toNamed(AppRoutes.orders);
  }

  /// Навигация на экран оплаты.
  void _navigateToPayment() {
    print('📱 Навигация на экран оплаты');
    Get.toNamed(AppRoutes.payment);
  }

  /// Навигация на экран настроек.
  void _navigateToSettings() {
    print('📱 Навигация на экран настроек');
    Get.toNamed(AppRoutes.settings);
  }

  /// Навигация на главный экран.
  void _navigateToMain() {
    print('📱 Навигация на главный экран');
    Get.toNamed(AppRoutes.main);
  }

  /// Навигация на указанный экран.
  void _navigateToScreen(String screen, Map<String, dynamic> data) {
    print('📱 Навигация на экран: $screen');
    switch (screen.toLowerCase()) {
      case 'orders':
      case '/orders':
        _navigateToOrders();
        break;
      case 'order_details':
      case '/order-details':
        final String? orderId = data['order_id'] as String?;
        if (orderId != null) {
          _navigateToOrderDetails(orderId, data);
        } else {
          _navigateToOrders();
        }
        break;
      case 'payment':
      case '/payment':
        _navigateToPayment();
        break;
      case 'settings':
      case '/settings':
        _navigateToSettings();
        break;
      case 'main':
      case '/main':
        _navigateToMain();
        break;
      default:
        _navigateToMain();
        break;
    }
  }

  /// Показывает уведомление из RemoteMessage.
  Future<void> executeShowNotificationFromRemoteMessage(
    RemoteMessage message,
  ) async {
    await executeInit();
    final RemoteNotification? notification = message.notification;
    if (notification == null) {
      print('⚠️ Уведомление пустое');
      return;
    }
    print('🔔 Показываю уведомление: ${notification.title} - ${notification.body}');
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      print('📋 Разрешение на уведомления: $granted');
    }
    // Проверяем наличие изображения в данных уведомления
    final String? imageUrl = message.data['image_url'] as String? ??
        message.data['image'] as String?;
    final NotificationDetails notificationDetails =
        await _createNotificationDetails(imageUrl);
    try {
      await plugin.show(
        notification.hashCode,
        notification.title ?? 'Новое уведомление',
        notification.body ?? '',
        notificationDetails,
        payload: jsonEncode(message.data),
      );
      print('✅ Уведомление успешно показано (ID: ${notification.hashCode})');
    } catch (e) {
      print('❌ Ошибка при показе уведомления: $e');
    }
  }

  /// Показывает уведомление из data payload.
  Future<void> executeShowDataNotification(RemoteMessage message) async {
    await executeInit();
    final String title = message.data['title'] ?? 'Новое уведомление';
    final String body = message.data['body'] ?? message.data['message'] ?? '';
    print('🔔 Показываю уведомление из data: $title - $body');
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      print('📋 Разрешение на уведомления: $granted');
    }
    // Проверяем наличие изображения в данных уведомления
    final String? imageUrl = message.data['image_url'] as String? ??
        message.data['image'] as String?;
    final NotificationDetails notificationDetails =
        await _createNotificationDetails(imageUrl);
    try {
      await plugin.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
      print('✅ Уведомление из data успешно показано (ID: ${message.hashCode})');
    } catch (e) {
      print('❌ Ошибка при показе уведомления из data: $e');
    }
  }

  /// Создает детали уведомления с поддержкой изображений.
  Future<NotificationDetails> _createNotificationDetails(
    String? imageUrl,
  ) async {
    StyleInformation? androidStyleInformation;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      print('🖼️ Добавляю изображение в уведомление: $imageUrl');
      try {
        final Uri uri = Uri.parse(imageUrl);
        final http.Response response = await http.get(uri);
        if (response.statusCode == 200) {
          final Directory tempDir =
              await Directory.systemTemp.createTemp('mopup_notif_');
          final File imageFile = File('${tempDir.path}/image');
          await imageFile.writeAsBytes(response.bodyBytes);
          final FilePathAndroidBitmap bitmap =
              FilePathAndroidBitmap(imageFile.path);
          androidStyleInformation = BigPictureStyleInformation(
            bitmap,
            largeIcon: bitmap,
            contentTitle: '',
            summaryText: '',
          );
          print('✅ Изображение добавлено в уведомление');
        } else {
          print('⚠️ Не удалось загрузить изображение: HTTP ${response.statusCode}');
          androidStyleInformation = const BigTextStyleInformation('');
        }
      } catch (e) {
        print('⚠️ Ошибка при добавлении изображения: $e');
        // Если не удалось добавить изображение, используем обычный стиль
        androidStyleInformation = const BigTextStyleInformation('');
      }
    } else {
      androidStyleInformation = const BigTextStyleInformation('');
    }
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _orderCreatedChannelId,
      _orderCreatedChannelName,
      channelDescription: _orderCreatedChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@drawable/ic_stat_name',
      styleInformation: androidStyleInformation,
    );
    // Для iOS изображения поддерживаются через attachments в notification payload
    // flutter_local_notifications не поддерживает прямую загрузку изображений для iOS
    // Изображения должны быть включены в FCM payload как attachment через fcm_options
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  /// Проверяет, предоставлены ли разрешения на уведомления.
  Future<bool> executeCheckNotificationPermissions() async {
    await executeInit();
    // Проверяем разрешения через Firebase Messaging (работает на iOS и Android)
    final NotificationSettings settings = await firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Запрашивает разрешения на показ уведомлений.
  Future<void> executeRequestPermissions() async {
    print('🔐 Запрос разрешений на уведомления...');
    // Сначала запрашиваем Android разрешения (для Android 13+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? androidGranted = await androidImplementation.requestNotificationsPermission();
      print('📱 Android разрешение на уведомления: $androidGranted');
      if (androidGranted == false) {
        print('⚠️ ВНИМАНИЕ: Разрешение на уведомления не предоставлено!');
        print('⚠️ Пользователь должен разрешить уведомления в настройках приложения');
      } else if (androidGranted == true) {
        print('✅ Android разрешение на уведомления предоставлено');
      }
    }
    // Затем запрашиваем iOS разрешения
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('✅ iOS разрешения запрошены');
    }
    // Затем запрашиваем macOS разрешения
    final MacOSFlutterLocalNotificationsPlugin? macImplementation =
        plugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    if (macImplementation != null) {
      await macImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('✅ macOS разрешения запрошены');
    }
    // И наконец запрашиваем Firebase разрешения (в основном для iOS)
    await _executeRequestFirebasePermissions();
    print('✅ Все разрешения запрошены');
  }

  /// Получает FCM токен.
  Future<String?> executeGetFCMToken() async {
    if (fcmToken == null) {
      await _executeGetFCMToken();
    }
    return fcmToken;
  }

  /// Обрабатывает начальное сообщение, если приложение было открыто из уведомления.
  Future<RemoteMessage?> executeGetInitialMessage() async {
    return await firebaseMessaging.getInitialMessage();
  }

  /// Подписывается на топик.
  Future<void> executeSubscribeToTopic(String topic) async {
    await firebaseMessaging.subscribeToTopic(topic);
  }

  /// Отписывается от топика.
  Future<void> executeUnsubscribeFromTopic(String topic) async {
    await firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Показывает уведомление о создании заказа.
  Future<void> executeShowOrderCreatedNotification() async {
    await executeInit();
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _orderCreatedChannelId,
      _orderCreatedChannelName,
      channelDescription: _orderCreatedChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
    await plugin.show(
      1,
      'Заказ создан',
      'Ваш заказ успешно создан.',
      notificationDetails,
    );
  }

  /// Показывает уведомление об удалении заказа.
  Future<void> executeShowOrderDeletedNotification() async {
    await executeInit();
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _orderCreatedChannelId,
      _orderCreatedChannelName,
      channelDescription: _orderCreatedChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
    await plugin.show(
      2,
      'Заказ удалён',
      'Ваш заказ успешно удалён.',
      notificationDetails,
    );
  }

  /// Показывает уведомление об ошибке.
  Future<void> executeShowErrorNotification(String message) async {
    await executeInit();
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _errorChannelId,
      _errorChannelName,
      channelDescription: _errorChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
    await plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Ошибка',
      message,
      notificationDetails,
    );
  }
}


