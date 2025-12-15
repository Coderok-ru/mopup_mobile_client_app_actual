/// Дополнительная услуга шаблона заказа.
class OrderAdditionalServiceEntity {
  /// Идентификатор услуги.
  final int id;

  /// Название услуги.
  final String title;

  /// Цена услуги.
  final double price;

  /// Время выполнения услуги.
  final int durationMinutes;

  /// Позиция услуги.
  final int position;

  /// Тип услуги.
  final String? type;

  /// Значение по умолчанию.
  final double defaultValue;

  /// Значение переключателя.
  final int defaultToggle;

  /// Создает сущность дополнительной услуги.
  const OrderAdditionalServiceEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.durationMinutes,
    required this.position,
    required this.defaultValue,
    required this.defaultToggle,
    this.type,
  });

  /// Создает сущность из JSON.
  factory OrderAdditionalServiceEntity.fromJson(Map<String, dynamic> json) {
    final int id = _readInt(json, <String>['id', 'service_id']);
    final String title = _readString(json, <String>['title', 'name', 'label']);
    final double price = _resolvePrice(json);
    final int durationMinutes = _readInt(json, <String>[
      'time',
      'duration',
    ], fallback: 0);
    final int position = _readInt(json, <String>[
      'position',
      'sort',
      'order',
    ], fallback: 0);
    final String? type = _readOptionalString(json, <String>[
      'type',
      'input_type',
    ]);
    final double defaultValue = _readDouble(json, <String>[
      'default_value',
      'value',
      'quantity',
    ], fallback: 0);
    final int defaultToggle = _readInt(json, <String>[
      'toggle_value',
      'checked',
      'toggle',
    ], fallback: 0);
    return OrderAdditionalServiceEntity(
      id: id,
      title: title,
      price: price,
      durationMinutes: durationMinutes,
      position: position,
      type: type,
      defaultValue: defaultValue,
      defaultToggle: defaultToggle,
    );
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
    return 'Дополнительная услуга';
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
