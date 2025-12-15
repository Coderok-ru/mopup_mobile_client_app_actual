import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';

/// Слайдер базовой услуги с отображением делений.
class BaseServiceSlider extends StatelessWidget {
  /// Минимальное значение.
  final int min;

  /// Максимальное значение.
  final int max;

  /// Текущее значение.
  final int value;

  /// Обработчик изменения значения.
  final ValueChanged<int> onChanged;

  /// Набор кастомных шагов.
  final List<int>? steps;

  /// Создает виджет слайдера базовой услуги.
  const BaseServiceSlider({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.steps,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> ticks = _resolveTicks();
    if (ticks.isEmpty) {
      return const SizedBox.shrink();
    }
    final int minIndex = 0;
    final int maxIndex = ticks.length - 1;
    final int currentIndex = _resolveIndex(ticks, value).clamp(minIndex, maxIndex);
    final int current = ticks[currentIndex];
    final double sliderValue = currentIndex.toDouble();
    final double sliderMin = minIndex.toDouble();
    final double sliderMax = maxIndex.toDouble();
    final int divisions = maxIndex > minIndex ? maxIndex - minIndex : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 28,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double labelWidth = 24;
              const double labelHalf = labelWidth / 2;
              final double width = constraints.maxWidth;
              final double maxLeft = width - labelWidth;
              final List<Widget> labels = List<Widget>.generate(ticks.length, (
                int index,
              ) {
                final int tick = ticks[index];
                final double fraction = ticks.length <= 1
                    ? 0
                    : index / (ticks.length - 1);
                double left = fraction * width - labelHalf;
                left = left.clamp(0, maxLeft);
                return Positioned(
                  left: left,
                  width: labelWidth,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      tick.toString(),
                      style: AppTypography.createBody13(AppColors.grayDark),
                    ),
                  ),
                );
              });
              return Stack(children: labels);
            },
          ),
        ),
        const SizedBox(height: 2),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 24,
            activeTrackColor: AppColors.mainPink,
            inactiveTrackColor: AppColors.grayLight.withValues(alpha: 0.3),
            thumbColor: AppColors.mainPink,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            overlayColor: AppColors.mainPink.withValues(alpha: 0.12),
            valueIndicatorColor: AppColors.mainPink,
            valueIndicatorTextStyle: AppTypography.createBody13(
              AppColors.white,
            ),
            inactiveTickMarkColor: Colors.transparent,
            activeTickMarkColor: Colors.transparent,
            trackShape: const _FullWidthRoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: sliderValue,
            min: sliderMin,
            max: sliderMax,
            divisions: divisions,
            label: current.toString(),
            onChanged: (double newValue) {
              HapticUtils.executeSelectionClick();
              final int roundedIndex =
                  newValue.round().clamp(minIndex, maxIndex);
              onChanged(ticks[roundedIndex]);
            },
          ),
        ),
      ],
    );
  }

  List<int> _resolveTicks() {
    if (steps != null && steps!.isNotEmpty) {
      final List<int> sorted = List<int>.from(steps!);
      sorted.sort();
      final List<int> unique = <int>[];
      for (final int item in sorted) {
        if (unique.isEmpty || unique.last != item) {
          unique.add(item);
        }
      }
      return unique;
    }
    final int clampedMin = min <= max ? min : max;
    final int clampedMax = max >= clampedMin ? max : clampedMin;
    return List<int>.generate(
      (clampedMax - clampedMin) + 1,
      (int index) => clampedMin + index,
    );
  }

  int _resolveIndex(List<int> ticks, int target) {
    final int directIndex = ticks.indexOf(target);
    if (directIndex >= 0) {
      return directIndex;
    }
    int nearestIndex = 0;
    int minDiff = (ticks[0] - target).abs();
    for (int i = 1; i < ticks.length; i++) {
      final int diff = (ticks[i] - target).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearestIndex = i;
      } else if (diff == minDiff && ticks[i] < ticks[nearestIndex]) {
        nearestIndex = i;
      }
    }
    return nearestIndex;
  }
}

class _FullWidthRoundedRectSliderTrackShape
    extends RoundedRectSliderTrackShape {
  const _FullWidthRoundedRectSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
