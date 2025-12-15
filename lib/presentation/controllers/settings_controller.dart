import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/services/notifications/notification_service.dart';
import '../../data/services/permissions/permissions_service.dart';

/// Контроллер экрана настроек.
class SettingsController extends GetxController {
  /// Локальное хранилище.
  final GetStorage storage;

  /// Сервис локальных уведомлений.
  final NotificationService notificationService;

  /// Сервис разрешений.
  final PermissionsService permissionsService;

  static const String _keyOrderStatusNotifications =
      'notifications_order_status_enabled';
  static const String _keyRemindersNotifications =
      'notifications_reminders_enabled';
  static const String _keyMarketingNotifications =
      'notifications_marketing_enabled';
  static const String _keyLocationAccess = 'location_access_enabled';

  /// Признак включенных уведомлений о статусе заказов.
  final RxBool isOrderStatusNotificationsEnabled = true.obs;

  /// Признак включенных напоминаний об уборках.
  final RxBool isRemindersNotificationsEnabled = true.obs;

  /// Признак включенных маркетинговых уведомлений.
  final RxBool isMarketingNotificationsEnabled = false.obs;

  /// Признак включенного доступа к местоположению.
  final RxBool isLocationAccessEnabled = false.obs;

  /// Создает контроллер настроек.
  SettingsController({
    required this.storage,
    required this.notificationService,
    required this.permissionsService,
  });

  @override
  void onInit() {
    super.onInit();
    loadNotificationSettings();
    checkPermissionsAndSync();
  }

  /// Проверяет разрешения и синхронизирует состояние переключателей.
  Future<void> checkPermissionsAndSync() async {
    final bool hasNotificationPermission =
        await notificationService.executeCheckNotificationPermissions();
    if (hasNotificationPermission) {
      isOrderStatusNotificationsEnabled.value = true;
      await storage.write(_keyOrderStatusNotifications, true);
    } else {
      // Если разрешение не дано, выключаем переключатель
      isOrderStatusNotificationsEnabled.value = false;
      await storage.write(_keyOrderStatusNotifications, false);
    }
    final bool hasLocationPermission =
        await permissionsService.executeCheckLocationPermission();
    if (hasLocationPermission) {
      isLocationAccessEnabled.value = true;
      await storage.write(_keyLocationAccess, true);
    } else {
      // Если разрешение не дано, выключаем переключатель
      isLocationAccessEnabled.value = false;
      await storage.write(_keyLocationAccess, false);
    }
  }

  /// Загружает настройки уведомлений из локального хранилища.
  void loadNotificationSettings() {
    final bool? storedOrderStatus =
        storage.read<bool>(_keyOrderStatusNotifications);
    final bool? storedReminders =
        storage.read<bool>(_keyRemindersNotifications);
    final bool? storedMarketing =
        storage.read<bool>(_keyMarketingNotifications);
    final bool? storedLocationAccess =
        storage.read<bool>(_keyLocationAccess);
    if (storedOrderStatus != null) {
      isOrderStatusNotificationsEnabled.value = storedOrderStatus;
    }
    if (storedReminders != null) {
      isRemindersNotificationsEnabled.value = storedReminders;
    }
    if (storedMarketing != null) {
      isMarketingNotificationsEnabled.value = storedMarketing;
    }
    if (storedLocationAccess != null) {
      isLocationAccessEnabled.value = storedLocationAccess;
    }
  }

  /// Изменяет настройку уведомлений о статусе заказов.
  Future<void> executeToggleOrderStatusNotifications(bool isEnabled) async {
    if (isEnabled) {
      // Запрашиваем разрешения
      await notificationService.executeRequestPermissions();
      // Проверяем, были ли разрешения предоставлены
      final bool hasPermission =
          await notificationService.executeCheckNotificationPermissions();
      if (hasPermission) {
        isOrderStatusNotificationsEnabled.value = true;
        await storage.write(_keyOrderStatusNotifications, true);
      } else {
        isOrderStatusNotificationsEnabled.value = false;
        await storage.write(_keyOrderStatusNotifications, false);
      }
    } else {
      isOrderStatusNotificationsEnabled.value = false;
      await storage.write(_keyOrderStatusNotifications, false);
    }
  }

  /// Изменяет настройку напоминаний об уборках.
  Future<void> executeToggleRemindersNotifications(bool isEnabled) async {
    isRemindersNotificationsEnabled.value = isEnabled;
    await storage.write(_keyRemindersNotifications, isEnabled);
    if (isEnabled) {
      await notificationService.executeRequestPermissions();
    }
  }

  /// Изменяет настройку маркетинговых уведомлений.
  Future<void> executeToggleMarketingNotifications(bool isEnabled) async {
    isMarketingNotificationsEnabled.value = isEnabled;
    await storage.write(_keyMarketingNotifications, isEnabled);
    if (isEnabled) {
      await notificationService.executeRequestPermissions();
    }
  }

  /// Изменяет настройку доступа к местоположению.
  Future<void> executeToggleLocationAccess(bool isEnabled) async {
    if (isEnabled) {
      final bool granted =
          await permissionsService.executeRequestLocationPermission();
      if (granted) {
        isLocationAccessEnabled.value = true;
        await storage.write(_keyLocationAccess, true);
      } else {
        isLocationAccessEnabled.value = false;
        await storage.write(_keyLocationAccess, false);
      }
    } else {
      isLocationAccessEnabled.value = false;
      await storage.write(_keyLocationAccess, false);
    }
  }
}


