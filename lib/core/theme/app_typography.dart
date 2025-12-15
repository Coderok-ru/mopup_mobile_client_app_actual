import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Набор текстовых стилей согласно макету.
class AppTypography {
  /// Тонкий текст размером 13.
  static TextStyle createBody13(Color color) {
    return GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.25,
      height: 1.4285714285714286,
      color: color,
    );
  }

  /// Основной текст размером 16.
  static TextStyle createBody16(Color color) {
    return GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.25,
      color: color,
    );
  }

  /// Заголовок размером 20.
  static TextStyle createTitle20(Color color) {
    return GoogleFonts.roboto(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.75,
      height: 1.171875,
      color: color,
    );
  }

  /// Заголовок размером 24.
  static TextStyle createTitle24(Color color) {
    return GoogleFonts.roboto(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.25,
      color: color,
    );
  }

  /// Акцентный заголовок логотипа.
  static TextStyle createLogoHeadline(Color color) {
    return GoogleFonts.oswald(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      height: 1.48,
      letterSpacing: 0.15,
      color: color,
    );
  }

  /// Крупное числовое значение рейтинга.
  static TextStyle createRatingValue(Color color) {
    return GoogleFonts.roboto(
      fontSize: 42,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1,
      color: color,
    );
  }

  /// Заголовок раздела FAQ рейтинга.
  static TextStyle createFaqTitle(Color color) {
    return GoogleFonts.oswald(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.25,
      height: 1.2307692308,
      color: color,
    );
  }

  /// Текст описания раздела FAQ рейтинга.
  static TextStyle createFaqDescription(Color color) {
    return GoogleFonts.roboto(
      fontSize: 13,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.25,
      height: 1.5384615385,
      color: color,
    );
  }
}
