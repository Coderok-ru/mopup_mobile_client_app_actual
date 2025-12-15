import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Формирует тему приложения.
class AppTheme {
  const AppTheme._();

  /// Создает светлую тему.
  static ThemeData createLightTheme() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.mainPink,
      primary: AppColors.mainPink,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onSurface: AppColors.grayDark,
      secondary: AppColors.accentBlue,
    );
    final TextTheme textTheme = GoogleFonts.robotoTextTheme().apply(
      bodyColor: AppColors.grayDark,
      displayColor: AppColors.grayDark,
    );
    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.grayDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.75,
          height: 1.171875,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
