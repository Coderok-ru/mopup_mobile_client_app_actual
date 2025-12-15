import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/datasources/order/order_template_remote_data_source.dart';
import '../../data/repositories/order/order_template_repository.dart';
import '../../data/repositories/order/order_template_repository_impl.dart';
import '../../data/services/notifications/notification_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/main_controller.dart';

/// Привязка зависимостей главного экрана.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OrderTemplateRemoteDataSource>()) {
      Get.lazyPut<OrderTemplateRemoteDataSource>(
        () => OrderTemplateRemoteDataSource(dio: Get.find<Dio>()),
      );
    }
    if (!Get.isRegistered<OrderTemplateRepository>()) {
      Get.lazyPut<OrderTemplateRepository>(
        () => OrderTemplateRepositoryImpl(
          remoteDataSource: Get.find<OrderTemplateRemoteDataSource>(),
        ),
      );
    }
    Get.lazyPut<MainController>(
      () => MainController(
        orderTemplateRepository: Get.find<OrderTemplateRepository>(),
        authController: Get.find<AuthController>(),
        notificationService: Get.find<NotificationService>(),
      ),
    );
  }
}
