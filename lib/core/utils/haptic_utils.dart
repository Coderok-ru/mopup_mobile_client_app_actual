import 'package:flutter/services.dart';

/// Утилиты для работы с виброоткликом.
class HapticUtils {
  /// Проигрывает легкий тактильный отклик при взаимодействии.
  static void executeSelectionClick() {
    HapticFeedback.selectionClick();
  }
}


