import 'checklist_row_entity.dart';

/// Модель секции таблицы чек-листа.
class ChecklistSectionEntity {
  /// Идентификатор секции.
  final int id;
  /// Название секции.
  final String name;
  /// Цвет фона секции.
  final String backgroundColor;
  /// Порядок отображения секции.
  final int order;
  /// Строки секции.
  final List<ChecklistRowEntity> rows;
  /// Создает модель секции.
  const ChecklistSectionEntity({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.order,
    required this.rows,
  });
  /// Создает модель из JSON.
  factory ChecklistSectionEntity.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rowsJson = json['rows'] as List<dynamic>? ?? [];
    return ChecklistSectionEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      backgroundColor: json['background_color'] as String? ?? '#ffffff',
      order: json['order'] as int? ?? 0,
      rows: rowsJson
          .map((dynamic item) => ChecklistRowEntity.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((ChecklistRowEntity a, ChecklistRowEntity b) => a.order.compareTo(b.order)),
    );
  }
}

