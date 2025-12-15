import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../controllers/launch_controller.dart';

/// Экран инициализации.
class LaunchView extends GetView<LaunchController> {
  /// Создает экран.
  const LaunchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.mainPink),
      ),
    );
  }
}
