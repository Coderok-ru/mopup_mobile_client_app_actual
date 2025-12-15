import 'dart:convert';

/// Скидка базовой услуги.
class OrderBaseServiceDiscount {
  /// Значение количества.
  final int value;

  /// Процент скидки.
  final int percent;

  /// Создает скидку базовой услуги.
  const OrderBaseServiceDiscount({
    required this.value,
    required this.percent,
  });

  /// Создает скидку из JSON.
  factory OrderBaseServiceDiscount.fromJson(Map<String, dynamic> json) {
    final int value = OrderBaseServiceEntity._readInt(
      json,
      <String>['value', 'count'],
      fallback: 0,
    );
    final int percent = OrderBaseServiceEntity._readInt(
      json,
      <String>['percent', 'discount'],
      fallback: 0,
    );
    return OrderBaseServiceDiscount(value: value, percent: percent);
  }
}

/// Базовая услуга шаблона заказа.
class OrderBaseServiceEntity {
  static const String _typeSingle = 'single';
  static const String _typeMulti = 'multy';

  /// Идентификатор услуги.
  final int id;

  /// Название услуги.
  final String title;

  /// Цена услуги.
  final double price;

  /// Длительность услуги в минутах.
  final int durationMinutes;

  /// Позиция услуги.
  final int position;

  /// Минимальное значение слайдера.
  final double minValue;

  /// Максимальное значение слайдера.
  final double maxValue;

  /// Шаг изменения значения.
  final double stepValue;

  /// Значение по умолчанию.
  final double defaultValue;

  /// Единица измерения.
  final String? unit;

  /// Тип услуги.
  final String type;

  /// Скидки для мультисервиса.
  final List<OrderBaseServiceDiscount> discounts;

  /// Создает сущность базовой услуги.
  const OrderBaseServiceEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.durationMinutes,
    required this.position,
    required this.minValue,
    required this.maxValue,
    required this.stepValue,
    required this.defaultValue,
    this.unit,
    required this.type,
    required this.discounts,
  });

  /// Создает сущность из JSON.
  factory OrderBaseServiceEntity.fromJson(Map<String, dynamic> json) {
    final int id = _readInt(json, <String>['id', 'service_id']);
    final String title = _readString(json, <String>['title', 'name', 'label']);
    final double price = _resolvePrice(json);
    final int durationMinutes = _readInt(json, <String>[
      'base_time',
      'duration',
      'time',
    ], fallback: 0);
    final int position = _readInt(json, <String>[
      'position',
      'sort',
      'order',
    ], fallback: 0);
    final double baseMinValue = 1;
    final double rawMaxValue = _readDouble(json, <String>[
      'value',
      'max_value',
      'quantity',
      'quantity_max',
    ], fallback: baseMinValue);
    final double stepValue = _readDouble(json, <String>[
      'step',
      'step_value',
    ], fallback: 1);
    final String type = _readType(json);
    final List<OrderBaseServiceDiscount> discounts = _parseDiscounts(json);
    double minValue = baseMinValue;
    double maxValue = rawMaxValue >= baseMinValue ? rawMaxValue : baseMinValue;
    if (type == _typeMulti && discounts.isNotEmpty) {
      minValue = discounts.first.value.toDouble();
      maxValue = discounts.last.value.toDouble();
    }
    final double defaultValue = minValue;
    final String? unit = _readOptionalString(json, <String>[
      'unit',
      'unit_name',
      'dimension',
    ]);
    return OrderBaseServiceEntity(
      id: id,
      title: title,
      price: price,
      durationMinutes: durationMinutes,
      position: position,
      minValue: minValue,
      maxValue: maxValue >= minValue ? maxValue : minValue,
      stepValue: stepValue > 0 ? stepValue : 1,
      defaultValue: _clamp(defaultValue, minValue, maxValue),
      unit: unit,
      type: type,
      discounts: discounts,
    );
  }

  /// Возвращает true, если услуга мульти.
  bool get isMulti => type == _typeMulti;

  /// Проверяет, используются ли скидки в мультишаблоне.
  bool useDiscountSteps(bool templateIsMulti) {
    return templateIsMulti && isMulti && discounts.isNotEmpty;
  }

  /// Возвращает доступные значения для слайдера.
  List<int> resolveAllowedValues(bool templateIsMulti) {
    if (useDiscountSteps(templateIsMulti)) {
      return discounts
          .map((OrderBaseServiceDiscount discount) => discount.value)
          .where((int value) => value > 0)
          .toList();
    }
    final int start = minValue.round();
    final int end = maxValue.round();
    final double step = stepValue <= 0 ? 1 : stepValue;
    final List<int> values = <int>[];
    double current = start.toDouble();
    while (current <= end + 0.0001) {
      values.add(current.round());
      current += step;
    }
    return values;
  }

  static List<OrderBaseServiceDiscount> _parseDiscounts(
    Map<String, dynamic> json,
  ) {
    final dynamic raw = json['discounts'];
    final List<dynamic> decoded = _decodeList(raw);
    final List<OrderBaseServiceDiscount> items =
        decoded.whereType<Map<String, dynamic>>().map((
      Map<String, dynamic> item,
    ) {
      return OrderBaseServiceDiscount.fromJson(item);
    }).where((OrderBaseServiceDiscount discount) => discount.value > 0).toList()
          ..sort(
            (OrderBaseServiceDiscount a, OrderBaseServiceDiscount b) =>
                a.value.compareTo(b.value),
          );
    return items;
  }

  static List<dynamic> _decodeList(dynamic raw) {
    if (raw is List<dynamic>) {
      return raw;
    }
    if (raw is String) {
      final String trimmed = raw.trim();
      if (trimmed.isEmpty) {
        return <dynamic>[];
      }
      try {
        final dynamic parsed = jsonDecode(trimmed);
        if (parsed is List<dynamic>) {
          return parsed;
        }
      } catch (_) {}
    }
    return <dynamic>[];
  }

  static String _readType(Map<String, dynamic> json) {
    final dynamic raw = json['type'] ?? json['service_type'];
    if (raw is String && raw.trim().isNotEmpty) {
      final String value = raw.trim().toLowerCase();
      if (value == _typeMulti || value == 'multi') {
        return _typeMulti;
      }
      if (value == _typeSingle || value == 'single') {
        return _typeSingle;
      }
    }
    return _typeSingle;
  }

  static int _readInt(
    Map<String, dynamic> json,
    List<String> keys, {
    int fallback = 0,
  }) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is int) {
        return value;
      }
      if (value is String) {
        final int? parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return fallback;
  }

  static double _readDouble(
    Map<String, dynamic> json,
    List<String> keys, {
    double fallback = 0,
  }) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final double? parsed = double.tryParse(value.replaceAll(',', '.'));
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return fallback;
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return 'Услуга';
  }

  static String? _readOptionalString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static double _clamp(double value, double min, double max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  static double _resolvePrice(Map<String, dynamic> json) {
    final Map<String, dynamic>? pivot = _extractPivot(json);
    final double pivotPrice =
        _readDouble(pivot ?? <String, dynamic>{}, <String>['price', 'cost'], fallback: -1);
    if (pivotPrice >= 0) {
      return pivotPrice;
    }
    final List<dynamic>? cities = json['cities'] as List<dynamic>?;
    if (cities != null) {
      for (final dynamic city in cities) {
        if (city is Map<String, dynamic>) {
          final Map<String, dynamic>? cityPivot = _extractPivot(city);
          final double cityPrice =
              _readDouble(cityPivot ?? <String, dynamic>{}, <String>['price', 'cost'], fallback: -1);
          if (cityPrice >= 0) {
            return cityPrice;
          }
        }
      }
    }
    return _readDouble(json, <String>['price', 'city_price']);
  }

  static Map<String, dynamic>? _extractPivot(Map<String, dynamic> json) {
    final dynamic pivot = json['pivot'];
    if (pivot is Map<String, dynamic>) {
      return pivot;
    }
    return null;
  }
}
