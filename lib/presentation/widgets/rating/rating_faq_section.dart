import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/rating/rating_faq_section_entity.dart';

/// Отображает один раздел пояснений рейтинга.
class RatingFaqSection extends StatelessWidget {
  /// Данные раздела.
  final RatingFaqSectionEntity section;

  /// Создает виджет раздела FAQ.
  const RatingFaqSection({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          section.title,
          style: AppTypography.createFaqTitle(AppColors.mainPink),
        ),
        const SizedBox(height: 8),
        Text(
          section.description,
          style: AppTypography.createFaqDescription(AppColors.grayMedium),
        ),
      ],
    );
  }
}
