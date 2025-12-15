import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/rating/rating_faq_section_entity.dart';
import '../../../data/models/rating/rating_info_entity.dart';
import '../../controllers/rating_controller.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../widgets/common/primary_app_bar.dart';
import '../../widgets/rating/rating_faq_section.dart';
import '../../widgets/rating/rating_gauge.dart';

/// Экран рейтинга.
class RatingView extends GetView<RatingController> {
  /// Создает экран рейтинга.
  const RatingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(
        title: AppStrings.menuRating,
        canPop: true,
        hasMenu: true,
      ),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: Obx(() {
          if (controller.isBusy.value && controller.ratingInfo.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null &&
              controller.ratingInfo.value == null) {
            return _RatingErrorState(onRetry: controller.loadRating);
          }
          final RatingInfoEntity? info = controller.ratingInfo.value;
          if (info == null) {
            return const SizedBox.shrink();
          }
          final List<RatingFaqSectionEntity> sections = info.faqSections;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: RatingGauge(
                    ratingValue: controller.getRatingValueLabel(),
                    progress: controller.getProgress(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.getLastUpdateLabel(),
                  style: AppTypography.createFaqDescription(
                    AppColors.grayMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (controller.errorMessage.value != null) ...<Widget>[
                  const SizedBox(height: 16),
                  _RatingErrorBanner(message: controller.errorMessage.value!),
                ],
                const SizedBox(height: 32),
                for (int i = 0; i < sections.length; i++) ...<Widget>[
                  RatingFaqSection(section: sections[i]),
                  if (i != sections.length - 1) const SizedBox(height: 28),
                ],
                const SizedBox(height: 48),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Отображает состояние ошибки загрузки рейтинга.
class _RatingErrorState extends StatelessWidget {
  /// Обработчик повторной попытки.
  final Future<void> Function() onRetry;

  const _RatingErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Не удалось загрузить рейтинг.',
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
                side: const BorderSide(color: AppColors.grayMedium, width: 1.5),
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

/// Отображает уведомление об ошибке поверх данных.
class _RatingErrorBanner extends StatelessWidget {
  /// Сообщение для отображения.
  final String message;

  const _RatingErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorRed, width: 1),
      ),
      child: Text(
        message,
        style: AppTypography.createBody13(AppColors.errorRed),
        textAlign: TextAlign.center,
      ),
    );
  }
}
