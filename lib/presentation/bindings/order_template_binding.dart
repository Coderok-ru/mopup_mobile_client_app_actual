import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/datasources/order/order_template_remote_data_source.dart';
import '../../data/repositories/order/order_template_repository.dart';
import '../../data/repositories/order/order_template_repository_impl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_template_controller.dart';

/// Привязка зависимостей экрана шаблона.
class OrderTemplateBinding extends Bindings {
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
    Get.lazyPut<OrderTemplateController>(
      () => OrderTemplateController(
        orderTemplateRepository: Get.find<OrderTemplateRepository>(),
        authController: Get.find<AuthController>(),
      ),
    );
  }
}
