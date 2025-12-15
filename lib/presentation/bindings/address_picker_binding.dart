import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/datasources/address/address_local_data_source.dart';
import '../../data/repositories/address/address_repository.dart';
import '../../data/repositories/address/address_repository_impl.dart';
import '../../data/services/location/location_service.dart';
import '../../data/services/location/yandex_geocode_service.dart';
import '../controllers/address_picker_controller.dart';

/// Привязка зависимостей для выбора адреса.
class AddressPickerBinding extends Bindings {
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
    if (!Get.isRegistered<LocationService>()) {
      Get.put<LocationService>(LocationService(), permanent: true);
    }
    if (!Get.isRegistered<YandexGeocodeService>()) {
      Get.put<YandexGeocodeService>(YandexGeocodeService(), permanent: true);
    }
    Get.lazyPut<AddressPickerController>(
      () => AddressPickerController(
        addressRepository: Get.find<AddressRepository>(),
        locationService: Get.find<LocationService>(),
        geocodeService: Get.find<YandexGeocodeService>(),
      ),
    );
  }
}
