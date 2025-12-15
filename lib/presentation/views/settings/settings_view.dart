import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../controllers/settings_controller.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../widgets/common/primary_app_bar.dart';

/// Экран настроек приложения.
class SettingsView extends GetView<SettingsController> {
  /// Создает экран настроек.
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(
        title: AppStrings.menuSettings,
        canPop: true,
        hasMenu: true,
      ),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: Obx(
        () {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: <Widget>[
              Text(
                AppStrings.settingsNotificationsTitle,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
              const SizedBox(height: 12),
              _SettingsSwitchTile(
                title: AppStrings.settingsNotificationsOrderStatusTitle,
                subtitle:
                    AppStrings.settingsNotificationsOrderStatusDescription,
                value: controller.isOrderStatusNotificationsEnabled.value,
                onChanged: controller.executeToggleOrderStatusNotifications,
              ),
              const SizedBox(height: 8),
              _SettingsSwitchTile(
                title: AppStrings.settingsNotificationsRemindersTitle,
                subtitle:
                    AppStrings.settingsNotificationsRemindersDescription,
                value: controller.isRemindersNotificationsEnabled.value,
                onChanged: controller.executeToggleRemindersNotifications,
              ),
              const SizedBox(height: 8),
              _SettingsSwitchTile(
                title: AppStrings.settingsNotificationsMarketingTitle,
                subtitle:
                    AppStrings.settingsNotificationsMarketingDescription,
                value: controller.isMarketingNotificationsEnabled.value,
                onChanged: controller.executeToggleMarketingNotifications,
              ),
              const SizedBox(height: 8),
              _SettingsSwitchTile(
                title: AppStrings.settingsLocationAccessTitle,
                subtitle: AppStrings.settingsLocationAccessDescription,
                value: controller.isLocationAccessEnabled.value,
                onChanged: controller.executeToggleLocationAccess,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Элемент списка настроек с переключателем.
class _SettingsSwitchTile extends StatelessWidget {
  /// Заголовок.
  final String title;

  /// Описание.
  final String subtitle;

  /// Значение переключателя.
  final bool value;

  /// Обработчик изменения значения.
  final ValueChanged<bool> onChanged;

  /// Создает элемент списка настроек с переключателем.
  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTypography.createBody16(AppColors.grayDark),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.createBody13(AppColors.grayMedium),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: value,
            activeColor: AppColors.mainPink,
            trackColor: AppColors.grayLight,
            onChanged: (bool isEnabled) {
              HapticUtils.executeSelectionClick();
              onChanged(isEnabled);
            },
          ),
        ],
      ),
    );
  }
}

