import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/datasources/address/address_local_data_source.dart';
import '../../data/datasources/order/order_local_data_source.dart';
import '../../data/datasources/order/order_remote_data_source.dart';
import '../../data/repositories/address/address_repository.dart';
import '../../data/repositories/address/address_repository_impl.dart';
import '../../data/repositories/order/order_repository.dart';
import '../../data/repositories/order/order_repository_impl.dart';
import '../../data/services/notifications/notification_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_confirmation_controller.dart';
import '../controllers/order_template_controller.dart';

/// Привязка зависимостей экрана подтверждения заказа.
class OrderConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    GlobalBinding().dependencies();
    final GetStorage storage = Get.find<GetStorage>();
    if (!Get.isRegistered<AddressLocalDataSource>()) {
      Get.put<AddressLocalDataSource>(
        AddressLocalDataSource(storage: storage),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AddressRepository>()) {
      Get.put<AddressRepository>(
        AddressRepositoryImpl(
          localDataSource: Get.find<AddressLocalDataSource>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<OrderRemoteDataSource>()) {
      final Dio dio = Get.find<Dio>();
      Get.put<OrderRemoteDataSource>(
        OrderRemoteDataSource(dio: dio),
        permanent: true,
      );
    }
    if (!Get.isRegistered<OrderLocalDataSource>()) {
      Get.put<OrderLocalDataSource>(
        OrderLocalDataSource(storage: storage),
        permanent: true,
      );
    }
    if (!Get.isRegistered<OrderRepository>()) {
      Get.put<OrderRepository>(
        OrderRepositoryImpl(
          remoteDataSource: Get.find<OrderRemoteDataSource>(),
          localDataSource: Get.find<OrderLocalDataSource>(),
        ),
        permanent: true,
      );
    }
    Get.lazyPut<OrderConfirmationController>(
      () => OrderConfirmationController(
        templateController: Get.find<OrderTemplateController>(),
        authController: Get.find<AuthController>(),
        addressRepository: Get.find<AddressRepository>(),
        orderRepository: Get.find<OrderRepository>(),
        notificationService: Get.find<NotificationService>(),
      ),
    );
  }
}

