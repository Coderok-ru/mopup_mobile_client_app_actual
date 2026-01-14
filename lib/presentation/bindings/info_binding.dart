import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/bindings/global_binding.dart';
import '../../data/datasources/checklist/checklist_remote_data_source.dart';
import '../../data/datasources/settings/mobile_settings_remote_data_source.dart';
import '../../data/repositories/checklist/checklist_repository.dart';
import '../../data/repositories/checklist/checklist_repository_impl.dart';
import '../../data/repositories/settings/mobile_settings_repository.dart';
import '../../data/repositories/settings/mobile_settings_repository_impl.dart';
import '../controllers/info_controller.dart';

/// Привязка зависимостей для экрана информации об услугах.
class InfoBinding extends Bindings {
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
    if (!Get.isRegistered<ChecklistRemoteDataSource>()) {
      final Dio dio = Get.find<Dio>();
      Get.put<ChecklistRemoteDataSource>(
        ChecklistRemoteDataSource(dio: dio),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ChecklistRepository>()) {
      Get.put<ChecklistRepository>(
        ChecklistRepositoryImpl(
          remoteDataSource: Get.find<ChecklistRemoteDataSource>(),
        ),
        permanent: true,
      );
    }
    Get.lazyPut<InfoController>(
      () => InfoController(
        mobileSettingsRepository: Get.find<MobileSettingsRepository>(),
        checklistRepository: Get.find<ChecklistRepository>(),
      ),
    );
  }
}


