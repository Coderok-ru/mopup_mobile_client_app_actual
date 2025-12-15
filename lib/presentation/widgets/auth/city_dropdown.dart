import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/auth/city_entity.dart';

/// Выпадающий список городов.
class CityDropdown extends StatelessWidget {
  /// Доступные города.
  final List<CityEntity> cities;

  /// Выбранный идентификатор.
  final int? selectedId;

  /// Обработчик выбора.
  final ValueChanged<int?> onChanged;

  /// Создает виджет.
  const CityDropdown({
    required this.cities,
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = AppTypography.createBody16(AppColors.grayDark);
    final TextStyle hintStyle = AppTypography.createBody16(AppColors.grayLight);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: _cityDropdownContentPadding),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: cities.any((CityEntity city) => city.id == selectedId)
                  ? selectedId
                  : null,
              hint: Text(AppStrings.cityHint, style: hintStyle),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.grayDark,
              ),
              isExpanded: true,
              style: valueStyle,
              items: cities
                  .map(
                    (CityEntity city) => DropdownMenuItem<int>(
                      value: city.id,
                      child: Text(city.name, style: valueStyle),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        Container(
          height: _cityDropdownDividerHeight,
          color: AppColors.grayMedium,
        ),
      ],
    );
  }
}

const double _cityDropdownContentPadding = 12;
const double _cityDropdownDividerHeight = 1;
