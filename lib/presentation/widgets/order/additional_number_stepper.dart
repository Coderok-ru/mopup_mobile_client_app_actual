import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';

/// Счетчик числовых значений в стиле iOS.
class AdditionalNumberStepper extends StatelessWidget {
  /// Текущее значение.
  final int value;

  /// Обработчик увеличения.
  final VoidCallback onIncrement;

  /// Обработчик уменьшения.
  final VoidCallback onDecrement;

  /// Разрешение увеличения.
  final bool canIncrement;

  /// Разрешение уменьшения.
  final bool canDecrement;

  /// Создает счетчик.
  const AdditionalNumberStepper({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.canIncrement = true,
    this.canDecrement = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mainPink),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _RoundIconButton(
            icon: Icons.remove,
            onPressed: canDecrement ? onDecrement : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              value.toString(),
              style: AppTypography.createBody16(AppColors.grayDark),
            ),
          ),
          _RoundIconButton(
            icon: Icons.add,
            onPressed: canIncrement ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: isEnabled
            ? AppColors.mainPink
            : AppColors.grayLight.withValues(alpha: 0.3),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled
              ? () {
                  HapticUtils.executeSelectionClick();
                  onPressed!();
                }
              : null,
          customBorder: const CircleBorder(),
          child: Icon(icon, size: 16, color: AppColors.white),
        ),
      ),
    );
  }
}
