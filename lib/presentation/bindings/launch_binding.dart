import 'package:get/get.dart';

import '../../data/repositories/auth/auth_repository.dart';
import '../controllers/auth_controller.dart';
import '../controllers/launch_controller.dart';

/// Привязка стартового экрана.
class LaunchBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(authRepository: Get.find<AuthRepository>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<LaunchController>()) {
      Get.put<LaunchController>(
        LaunchController(authController: Get.find<AuthController>()),
      );
    }
  }
}
