/// Модель краткой информации о шаблоне заказа.
class OrderTemplateSummaryEntity {
  /// Идентификатор шаблона.
  final int id;

  /// Заголовок шаблона.
  final String title;

  /// Краткое описание шаблона.
  final String? description;

  /// Системный код шаблона.
  final String? slug;

  /// Создает сущность шаблона заказа.
  const OrderTemplateSummaryEntity({
    required this.id,
    required this.title,
    this.description,
    this.slug,
  });

  /// Создает сущность из JSON.
  factory OrderTemplateSummaryEntity.fromJson(Map<String, dynamic> json) {
    final int id = _readId(json);
    final String title = _readTitle(json);
    final String? description = _readOptionalString(json, <String>[
      'description',
      'short_description',
      'subtitle',
    ]);
    final String? slug = _readOptionalString(json, <String>[
      'slug',
      'code',
      'alias',
    ]);
    return OrderTemplateSummaryEntity(
      id: id,
      title: title,
      description: description,
      slug: slug,
    );
  }

  static int _readId(Map<String, dynamic> json) {
    final List<String> keys = <String>[
      'id',
      'template_id',
      'order_template_id',
      'templateId',
    ];
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
    return 0;
  }

  static String _readTitle(Map<String, dynamic> json) {
    final List<String> keys = <String>[
      'title',
      'name',
      'label',
      'display_name',
    ];
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return 'Шаблон';
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
}
