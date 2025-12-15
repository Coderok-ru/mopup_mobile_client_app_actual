import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/services/notifications/notification_service.dart';
import '../../data/services/permissions/permissions_service.dart';
import '../controllers/settings_controller.dart';

/// Привязка зависимостей для экрана настроек.
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    GlobalBinding().dependencies();
    if (!Get.isRegistered<PermissionsService>()) {
      Get.put<PermissionsService>(PermissionsService(), permanent: true);
    }
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        storage: Get.find<GetStorage>(),
        notificationService: Get.find<NotificationService>(),
        permissionsService: Get.find<PermissionsService>(),
      ),
      fenix: true,
    );
  }
}


