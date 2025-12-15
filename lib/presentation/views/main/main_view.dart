import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../controllers/main_controller.dart';
import '../../../data/models/order/order_template_summary_entity.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../widgets/common/primary_app_bar.dart';

/// Главный экран приложения со списком шаблонов услуг.
class MainView extends GetView<MainController> {
  /// Создает главный экран.
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(title: 'Mop’Up', hasMenu: true),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Expanded(child: _LogoCard()),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const _LoadingIndicator();
                    }
                    final String? error = controller.errorMessage.value;
                    if (error != null && error.isNotEmpty) {
                      return _StateMessage(message: error);
                    }
                    final List<OrderTemplateSummaryEntity> templates =
                        controller.templates;
                    if (templates.isEmpty) {
                      return const _StateMessage(
                        message: 'Шаблоны услуг отсутствуют.',
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 32, 18, 120),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: templates.length,
                      itemBuilder: (BuildContext context, int index) {
                        final OrderTemplateSummaryEntity template =
                            templates[index];
                        final bool isLast = index == templates.length - 1;
                        final String iconPath = _resolveIconPath(index);
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
                          child: _TemplateCard(
                            template: template,
                            iconPath: iconPath,
                            onTap: () => controller.openTemplate(template),
                          ),
                        );
                      },
                    );
                  }),
                  const _InfoButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Center(child: SvgPicture.asset(AppAssets.logo, width: 260)),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final OrderTemplateSummaryEntity template;
  final String iconPath;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticUtils.executeSelectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.grayDark,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      template.title,
                      style: AppTypography.createBody16(AppColors.grayDark),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 26,
                    color: AppColors.grayDark,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 1,
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 40),
                  color: AppColors.grayLight.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: 72,
            height: 72,
            child: IconButton(
              onPressed: () {
                HapticUtils.executeSelectionClick();
                Get.toNamed(AppRoutes.info);
              },
              icon: SvgPicture.asset(
                AppAssets.iconInfoSquare,
                width: 32,
                height: 32,
                colorFilter: const ColorFilter.mode(
                  AppColors.grayLight,
                  BlendMode.srcIn,
                ),
              ),
              splashRadius: 36,
              color: AppColors.grayLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _StateMessage extends StatelessWidget {
  final String message;

  const _StateMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.createBody13(AppColors.grayDark),
        ),
      ),
    );
  }
}

String _resolveIconPath(int index) {
  if (index == 0) {
    return AppAssets.iconFilterSchedule;
  }
  if (index == 1) {
    return AppAssets.iconFilterComfort;
  }
  if (index == 2) {
    return AppAssets.iconFilterVip;
  }
  return AppAssets.iconFilterComfort;
}
