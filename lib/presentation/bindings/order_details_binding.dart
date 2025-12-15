import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/datasources/order/order_local_data_source.dart';
import '../../data/datasources/order/order_remote_data_source.dart';
import '../../data/repositories/order/order_repository.dart';
import '../../data/repositories/order/order_repository_impl.dart';
import '../../data/repositories/favorite_cleaner/favorite_cleaner_repository.dart';
import '../../data/repositories/favorite_cleaner/favorite_cleaner_repository_impl.dart';
import '../controllers/order_details_controller.dart';

/// Привязка зависимостей экрана деталей заказа.
class OrderDetailsBinding extends Bindings {
  @override
  void dependencies() {
    GlobalBinding().dependencies();
    if (!Get.isRegistered<OrderRemoteDataSource>()) {
      final Dio dio = Get.find<Dio>();
      Get.put<OrderRemoteDataSource>(
        OrderRemoteDataSource(dio: dio),
        permanent: true,
      );
    }
    if (!Get.isRegistered<OrderLocalDataSource>()) {
      Get.put<OrderLocalDataSource>(
        OrderLocalDataSource(storage: Get.find<GetStorage>()),
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
    if (!Get.isRegistered<FavoriteCleanerRepository>()) {
      Get.put<FavoriteCleanerRepository>(
        FavoriteCleanerRepositoryImpl(dio: Get.find<Dio>()),
        permanent: true,
      );
    }
    Get.lazyPut<OrderDetailsController>(
      () => OrderDetailsController(
        orderRepository: Get.find<OrderRepository>(),
        favoriteCleanerRepository: Get.find<FavoriteCleanerRepository>(),
      ),
    );
  }
}


