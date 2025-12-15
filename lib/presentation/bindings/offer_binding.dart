import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/datasources/settings/mobile_settings_remote_data_source.dart';
import '../../data/repositories/settings/mobile_settings_repository.dart';
import '../../data/repositories/settings/mobile_settings_repository_impl.dart';
import '../controllers/offer_controller.dart';

/// Привязка зависимостей для экрана договора оферты.
class OfferBinding extends Bindings {
  @override
  void dependencies() {
    GlobalBinding().dependencies();
    if (!Get.isRegistered<MobileSettingsRemoteDataSource>()) {
      final Dio dio = Get.find<Dio>();
      Get.put<MobileSettingsRemoteDataSource>(
        MobileSettingsRemoteDataSource(dio: dio),
        permanent: true,
      );
    }
    if (!Get.isRegistered<MobileSettingsRepository>()) {
      Get.put<MobileSettingsRepository>(
        MobileSettingsRepositoryImpl(
          remoteDataSource: Get.find<MobileSettingsRemoteDataSource>(),
        ),
        permanent: true,
      );
    }
    Get.lazyPut<OfferController>(
      () => OfferController(
        mobileSettingsRepository: Get.find<MobileSettingsRepository>(),
      ),
    );
  }
}


