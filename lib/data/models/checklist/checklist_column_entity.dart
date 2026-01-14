/// Модель колонки таблицы чек-листа.
class ChecklistColumnEntity {
  /// Идентификатор колонки.
  final int id;
  /// Название колонки.
  final String name;
  /// Тип колонки.
  final String type;
  /// Порядок отображения колонки.
  final int order;
  /// Создает модель колонки.
  const ChecklistColumnEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.order,
  });
  /// Создает модель из JSON.
  factory ChecklistColumnEntity.fromJson(Map<String, dynamic> json) {
    return ChecklistColumnEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

