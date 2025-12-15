import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../routes/app_routes.dart';

/// Универсальный аппбар приложения.
class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Заголовок экрана.
  final String title;

  /// Показывает кнопку возврата.
  final bool canPop;

  /// Показывает кнопку меню.
  final bool hasMenu;

  /// Пользовательский обработчик возврата.
  final VoidCallback? onBackPressed;

  /// Создает основной аппбар.
  const PrimaryAppBar({
    required this.title,
    this.canPop = false,
    this.hasMenu = false,
    this.onBackPressed,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.grayDark,
      leading: canPop
          ? IconButton(
              onPressed: onBackPressed ??
                  () {
                    HapticFeedback.selectionClick();
                    Get.offAllNamed(AppRoutes.main);
                  },
              icon: const Icon(Icons.arrow_back_ios_new),
              color: AppColors.white,
            )
          : null,
      title: Text(title, style: AppTypography.createTitle20(AppColors.white)),
      actions: hasMenu
          ? <Widget>[
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.menu_outlined, size: 28),
                    color: AppColors.white,
                  );
                },
              ),
            ]
          : null,
    );
  }
}
