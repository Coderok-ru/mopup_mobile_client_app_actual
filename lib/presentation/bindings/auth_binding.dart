import 'package:get/get.dart';

import '../../data/repositories/auth/auth_repository.dart';
import '../controllers/auth_controller.dart';

/// Привязка зависимостей для модуля авторизации.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(authRepository: Get.find<AuthRepository>()),
        permanent: true,
      );
    }
  }
}
