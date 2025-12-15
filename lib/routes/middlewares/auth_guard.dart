import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../presentation/controllers/auth_controller.dart';
import '../app_routes.dart';

/// Защищает маршруты от доступа без авторизации.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final AuthController controller = Get.find<AuthController>();
    final bool isAuthorized = controller.isAuthenticated.value;
    if (!isAuthorized) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
