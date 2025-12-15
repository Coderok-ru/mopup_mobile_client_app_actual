import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Базовое поле для форм авторизации.
class AuthTextField extends StatelessWidget {
  /// Контроллер ввода.
  final TextEditingController controller;

  /// Текст-подсказка.
  final String hint;

  /// Тип клавиатуры.
  final TextInputType keyboardType;

  /// Скрывать ли текст.
  final bool obscureText;

  /// Показывать ли иконку подтверждения.
  final bool showCheck;

  /// Виджет справа (например, кастомная иконка).
  final Widget? trailing;

  /// Форматтеры ввода.
  final List<TextInputFormatter>? inputFormatters;

  /// Режим капитализации текста.
  final TextCapitalization textCapitalization;

  /// Обработчик нажатия.
  final VoidCallback? onTap;

  /// Поле только для чтения.
  final bool readOnly;

  /// Показывать ли курсор.
  final bool showCursor;

  /// Создает поле ввода.
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.showCheck = false,
    this.trailing,
    this.inputFormatters,
    this.onTap,
    this.readOnly = false,
    this.showCursor = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: _authTextFieldContentPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  inputFormatters: inputFormatters,
                  textCapitalization: textCapitalization,
                  readOnly: readOnly,
                  onTap: onTap,
                  showCursor: showCursor,
                  style: AppTypography.createBody16(AppColors.grayDark),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTypography.createBody16(AppColors.grayLight),
                    isDense: true,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showCheck)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.accentGreen,
                  size: _authTextFieldTrailingIconSize,
                ),
            ],
          ),
        ),
        Container(
          height: _authTextFieldDividerHeight,
          color: AppColors.grayMedium,
        ),
      ],
    );
  }
}

const double _authTextFieldContentPadding = 14;
const double _authTextFieldDividerHeight = 1;
const double _authTextFieldTrailingIconSize = 22;
