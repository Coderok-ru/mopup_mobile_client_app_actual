import 'package:get/get.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/services/location/yandex_geocode_service.dart';
import '../../data/services/location/yandex_search_service.dart';
import '../controllers/address_search_controller.dart';

/// Привязка зависимостей для поиска адреса.
class AddressSearchBinding extends Bindings {
  @override
  void dependencies() {
    GlobalBinding().dependencies();
    if (!Get.isRegistered<YandexSearchService>()) {
      Get.put<YandexSearchService>(
        YandexSearchService(),
        permanent: true,
      );
    }
    if (!Get.isRegistered<YandexGeocodeService>()) {
      Get.put<YandexGeocodeService>(
        YandexGeocodeService(),
        permanent: true,
      );
    }
    Get.lazyPut<AddressSearchController>(
      () => AddressSearchController(
        searchService: Get.find<YandexSearchService>(),
        geocodeService: Get.find<YandexGeocodeService>(),
      ),
    );
  }
}

