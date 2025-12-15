import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';

/// Кнопка входа через социальную сеть.
class SocialIconButton extends StatelessWidget {
  /// Путь к иконке.
  final String assetPath;

  /// Обработчик нажатия.
  final VoidCallback? onTap;

  /// Размер контейнера.
  final double size;

  /// Создает социальную кнопку.
  const SocialIconButton({
    super.key,
    required this.assetPath,
    this.onTap,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          assetPath,
          width: size * 0.68,
          height: size * 0.68,
        ),
      ),
    );
  }
}
