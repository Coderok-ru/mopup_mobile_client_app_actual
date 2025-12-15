import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/datasources/auth/auth_local_data_source.dart';
import '../../data/datasources/auth/auth_remote_data_source.dart';
import '../../data/repositories/auth/auth_repository.dart';
import '../../data/repositories/auth/auth_repository_impl.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';

/// Глобальная привязка зависимостей.
class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GetStorage>()) {
      Get.put<GetStorage>(GetStorage(), permanent: true);
    }
    if (!Get.isRegistered<AuthLocalDataSource>()) {
      Get.put<AuthLocalDataSource>(
        AuthLocalDataSource(storage: Get.find<GetStorage>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<Dio>()) {
      final Dio dio = createDioClient();
      dio.interceptors.add(
        AuthInterceptor(localDataSource: Get.find<AuthLocalDataSource>()),
      );
      Get.put<Dio>(dio, permanent: true);
    }
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      Get.put<AuthRemoteDataSource>(
        AuthRemoteDataSource(dio: Get.find<Dio>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(
        AuthRepositoryImpl(
          remoteDataSource: Get.find<AuthRemoteDataSource>(),
          localDataSource: Get.find<AuthLocalDataSource>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(authRepository: Get.find<AuthRepository>()),
        permanent: true,
      );
    }
  }
}
