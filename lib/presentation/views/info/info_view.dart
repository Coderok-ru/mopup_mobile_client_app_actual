import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../controllers/info_controller.dart';
import '../../widgets/checklist/checklist_table_widget.dart';
import '../../widgets/common/primary_app_bar.dart';

/// Экран с описанием типов уборки.
class InfoView extends GetView<InfoController> {
  /// Создает экран описания типов уборки.
  const InfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(title: AppStrings.infoTitle, canPop: true),
      body: SafeArea(
        child: Obx(() {
          if (controller.isBusy.value && controller.checklist.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null &&
              controller.checklist.value == null) {
            return _InfoErrorState(onRetry: controller.loadInfo);
          }
          final checklist = controller.checklist.value;
          if (checklist == null) {
            return const SizedBox.shrink();
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ChecklistTableWidget(checklist: checklist),
          );
        }),
      ),
    );
  }
}

/// Отображает состояние ошибки загрузки информации.
class _InfoErrorState extends StatelessWidget {
  /// Обработчик повторной попытки.
  final Future<void> Function() onRetry;

  const _InfoErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Не удалось загрузить информацию.',
            style: AppTypography.createBody16(AppColors.grayMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            height: 42,
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grayMedium,
                side: const BorderSide(
                  color: AppColors.grayMedium,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                textStyle: AppTypography.createBody16(AppColors.grayMedium),
              ),
              child: const Text('Повторить'),
            ),
          ),
        ],
      ),
    );
  }
}

