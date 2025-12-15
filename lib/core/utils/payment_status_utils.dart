import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Утилиты для работы со статусами оплаты.
class PaymentStatusUtils {
  /// Маппинг статусов оплаты на русские названия.
  static const Map<String, String> _statusMap = <String, String>{
    'CONFIRMED': 'Заказ оплачен',
    'NEW': 'Заказ не оплачен',
    'FORM_SHOWED': 'Заказ не оплачен',
    'CANCELED': 'Заказ не оплачен',
    'REJECTED': 'Оплата отклонена',
    'AUTHORIZED': 'Оплата авторизована',
    'REVERSED': 'Оплата отменена',
    'REFUNDED': 'Оплата возвращена',
    'DEADLINE_EXPIRED': 'Автоматическое закрытие сессии',
    'CHECKED': 'Оплата проверена',
    'COMPLETED': 'Оплата завершена',
  };

  /// Статусы с зеленым цветом.
  static const Set<String> _greenStatuses = <String>{
    'CONFIRMED',
    'COMPLETED',
    'CHECKED',
  };

  /// Статусы с серым цветом.
  static const Set<String> _grayStatuses = <String>{
    'FORM_SHOWED',
    'AUTHORIZED',
  };

  /// Возвращает русское название статуса оплаты.
  static String getStatusText(String? status) {
    if (status == null || status.isEmpty) {
      return 'Не оплачен';
    }
    final String upperStatus = status.toUpperCase();
    return _statusMap[upperStatus] ?? status;
  }

  /// Возвращает цвет для статуса оплаты.
  static Color getStatusColor(String? status) {
    if (status == null || status.isEmpty) {
      return AppColors.errorRed;
    }
    final String upperStatus = status.toUpperCase();
    if (_greenStatuses.contains(upperStatus)) {
      return AppColors.accentGreen;
    }
    if (_grayStatuses.contains(upperStatus)) {
      return AppColors.grayMedium;
    }
    return AppColors.errorRed;
  }
}

