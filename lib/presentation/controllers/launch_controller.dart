import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'auth_controller.dart';

/// Контроллер стартового экрана.
class LaunchController extends GetxController {
  /// Контроллер авторизации.
  final AuthController authController;

  /// Создает контроллер.
  LaunchController({required this.authController});

  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    final bool hasActiveSession = await authController.hasSession();
    if (hasActiveSession) {
      Get.offAllNamed(AppRoutes.main);
      return;
    }
    Get.offAllNamed(AppRoutes.login);
  }
}
