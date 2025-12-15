import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Индикатор визуализации рейтинга.
class RatingGauge extends StatelessWidget {
  /// Отформатированное значение рейтинга.
  final String ratingValue;

  /// Прогресс в диапазоне [0;1].
  final double progress;

  /// Создает индикатор рейтинга.
  const RatingGauge({
    required this.ratingValue,
    required this.progress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double normalized = progress.clamp(0, 1);
    return SizedBox(
      width: 240,
      height: 160,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 5,
            startAngle: 180,
            endAngle: 0,
            showTicks: false,
            showLabels: false,
            canScaleToFit: true,
            radiusFactor: 0.95,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.001,
              thicknessUnit: GaugeSizeUnit.factor,
              color: Colors.transparent,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: 5,
                sizeUnit: GaugeSizeUnit.factor,
                width: 0.24,
                cornerStyle: CornerStyle.bothCurve,
                color: AppColors.grayLight,
              ),
              RangePointer(
                value: normalized * 5,
                sizeUnit: GaugeSizeUnit.factor,
                width: 0.24,
                cornerStyle: CornerStyle.bothCurve,
                color: AppColors.accentGreen,
              ),
              MarkerPointer(
                value: normalized * 5,
                markerType: MarkerType.circle,
                enableAnimation: false,
                markerWidth: 32,
                markerHeight: 32,
                color: AppColors.white,
                borderColor: AppColors.accentGreen,
                borderWidth: 10,
                offsetUnit: GaugeSizeUnit.factor,
                markerOffset: 0.1,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                angle: 90,
                positionFactor: 0.0,
                widget: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    ratingValue,
                    style: AppTypography.createRatingValue(
                      AppColors.grayMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
