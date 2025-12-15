import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/datasources/address/address_local_data_source.dart';
import '../../data/repositories/address/address_repository.dart';
import '../../data/repositories/address/address_repository_impl.dart';
import '../../data/services/notifications/notification_service.dart';
import '../controllers/order_schedule_controller.dart';
import '../controllers/order_template_controller.dart';

/// Привязка зависимостей экрана выбора даты и времени.
class OrderScheduleBinding extends Bindings {
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
    Get.lazyPut<OrderScheduleController>(
      () => OrderScheduleController(
        templateController: Get.find<OrderTemplateController>(),
        addressRepository: Get.find<AddressRepository>(),
        storage: storage,
        notificationService: Get.find<NotificationService>(),
      ),
    );
  }
}
