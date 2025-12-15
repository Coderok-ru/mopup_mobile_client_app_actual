import 'order_additional_service_entity.dart';
import 'order_base_service_entity.dart';

/// Детальная информация о шаблоне заказа.
class OrderTemplateDetailEntity {
  /// Идентификатор шаблона.
  final int id;

  /// Название шаблона.
  final String title;

  /// Тип шаблона.
  final String type;

  /// Базовая стоимость шаблона.
  final double basePrice;

  /// Базовое время выполнения шаблона.
  final int baseTime;

  /// Базовые услуги.
  final List<OrderBaseServiceEntity> baseServices;

  /// Дополнительные услуги.
  final List<OrderAdditionalServiceEntity> additionalServices;

  /// Возвращает true, если шаблон мульти.
  bool get isMulti => type == 'multy';

  /// Создает детальную сущность шаблона.
  const OrderTemplateDetailEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.basePrice,
    required this.baseTime,
    required this.baseServices,
    required this.additionalServices,
  });

  /// Создает сущность из JSON.
  factory OrderTemplateDetailEntity.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = _extractData(json);
    final Map<String, dynamic> template = _extractTemplate(data);
    final int id = _readInt(template, <String>['id', 'template_id', 'templateId']);
    final String title = _readString(template, <String>['title', 'name', 'label']);
    final String type = _resolveType(json, data, template);
    final double basePrice = _resolveTemplatePrice(template);
    final int baseTime = _readInt(template, <String>['base_time', 'baseTime'], fallback: 0);
    final List<OrderBaseServiceEntity> base = _parseBaseServices(data);
    final List<OrderAdditionalServiceEntity> additional =
        _parseAdditionalServices(data);
    return OrderTemplateDetailEntity(
      id: id,
      title: title,
      type: type,
      basePrice: basePrice,
      baseTime: baseTime,
      baseServices: base,
      additionalServices: additional,
    );
  }

  static Map<String, dynamic> _extractData(Map<String, dynamic> json) {
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(json['data'] as Map<String, dynamic>);
    }
    if (json.containsKey('template') &&
        json['template'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(
        json['template'] as Map<String, dynamic>,
      );
    }
    return json;
  }

  static List<OrderBaseServiceEntity> _parseBaseServices(
    Map<String, dynamic> data,
  ) {
    dynamic items = data['base_services'] ?? data['baseServices'];
    if (items is! List<dynamic>) {
      final Map<String, dynamic> template = _extractTemplate(data);
      items = template['base_services'] ?? template['baseServices'];
    }
    if (items is List<dynamic>) {
      return items.whereType<Map<String, dynamic>>().map((
        Map<String, dynamic> item,
      ) {
        return OrderBaseServiceEntity.fromJson(item);
      }).toList()..sort(
        (OrderBaseServiceEntity a, OrderBaseServiceEntity b) =>
            a.position.compareTo(b.position),
      );
    }
    return <OrderBaseServiceEntity>[];
  }

  static List<OrderAdditionalServiceEntity> _parseAdditionalServices(
    Map<String, dynamic> data,
  ) {
    dynamic items =
        data['additional_services'] ?? data['additionalServices'];
    if (items is! List<dynamic>) {
      final Map<String, dynamic> template = _extractTemplate(data);
      items = template['additional_services'] ?? template['additionalServices'];
    }
    if (items is List<dynamic>) {
      return items.whereType<Map<String, dynamic>>().map((
        Map<String, dynamic> item,
      ) {
        return OrderAdditionalServiceEntity.fromJson(item);
      }).toList()..sort(
        (OrderAdditionalServiceEntity a, OrderAdditionalServiceEntity b) =>
            a.position.compareTo(b.position),
      );
    }
    return <OrderAdditionalServiceEntity>[];
  }

  static Map<String, dynamic> _extractTemplate(Map<String, dynamic> data) {
    if (data.containsKey('template') && data['template'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['template'] as Map<String, dynamic>);
    }
    return data;
  }

  static double _resolveTemplatePrice(Map<String, dynamic> template) {
    final Map<String, dynamic>? pivot = _extractPivot(template);
    final double pivotPrice =
        _readDouble(pivot ?? <String, dynamic>{}, <String>['price', 'cost'], fallback: -1);
    if (pivotPrice >= 0) {
      return pivotPrice;
    }
    final List<dynamic>? cities = template['cities'] as List<dynamic>?;
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
    return _readDouble(template, <String>['price', 'city_price']);
  }

  static Map<String, dynamic>? _extractPivot(Map<String, dynamic> json) {
    final dynamic pivot = json['pivot'];
    if (pivot is Map<String, dynamic>) {
      return pivot;
    }
    return null;
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

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return 'Шаблон';
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

  static String _resolveType(
    Map<String, dynamic> origin,
    Map<String, dynamic> data,
    Map<String, dynamic> template,
  ) {
    final String fromTemplate = _readTypeValue(template);
    if (fromTemplate.isNotEmpty) {
      return fromTemplate;
    }
    final String fromData = _readTypeValue(data);
    if (fromData.isNotEmpty) {
      return fromData;
    }
    final String fromOrigin = _readTypeValue(origin);
    if (fromOrigin.isNotEmpty) {
      return fromOrigin;
    }
    return 'single';
  }

  static String _readTypeValue(Map<String, dynamic> source) {
    final List<String> keys = <String>[
      'type',
      'order_type',
      'orderType',
      'template_type',
      'templateType',
    ];
    for (final String key in keys) {
      final dynamic value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        final String normalized = value.trim().toLowerCase();
        if (normalized == 'multy' || normalized == 'multi') {
          return 'multy';
        }
        if (normalized == 'single' || normalized == 'one_time') {
          return 'single';
        }
      }
    }
    return '';
  }
}
