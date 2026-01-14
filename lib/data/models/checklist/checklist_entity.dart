import 'checklist_column_entity.dart';
import 'checklist_section_entity.dart';

/// Модель чек-листа.
class ChecklistEntity {
  /// Идентификатор чек-листа.
  final int id;
  /// Название чек-листа.
  final String name;
  /// Описание чек-листа.
  final String description;
  /// Признак наличия заголовка.
  final bool hasHeader;
  /// Колонки таблицы.
  final List<ChecklistColumnEntity> columns;
  /// Секции таблицы.
  final List<ChecklistSectionEntity> sections;
  /// Создает модель чек-листа.
  const ChecklistEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.hasHeader,
    required this.columns,
    required this.sections,
  });
  /// Создает модель из JSON.
  factory ChecklistEntity.fromJson(Map<String, dynamic> json) {
    final List<dynamic> columnsJson = json['columns'] as List<dynamic>? ?? [];
    final List<dynamic> sectionsJson = json['sections'] as List<dynamic>? ?? [];
    return ChecklistEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      hasHeader: json['has_header'] as bool? ?? false,
      columns: columnsJson
          .map((dynamic item) => ChecklistColumnEntity.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((ChecklistColumnEntity a, ChecklistColumnEntity b) => a.order.compareTo(b.order)),
      sections: sectionsJson
          .map((dynamic item) => ChecklistSectionEntity.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((ChecklistSectionEntity a, ChecklistSectionEntity b) => a.order.compareTo(b.order)),
    );
  }
}

