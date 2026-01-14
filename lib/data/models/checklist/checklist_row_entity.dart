import 'checklist_cell_entity.dart';

/// Модель строки таблицы чек-листа.
class ChecklistRowEntity {
  /// Идентификатор строки.
  final int id;
  /// Название услуги.
  final String serviceName;
  /// Порядок отображения строки.
  final int order;
  /// Ячейки строки.
  final List<ChecklistCellEntity> cells;
  /// Создает модель строки.
  const ChecklistRowEntity({
    required this.id,
    required this.serviceName,
    required this.order,
    required this.cells,
  });
  /// Создает модель из JSON.
  factory ChecklistRowEntity.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cellsJson = json['cells'] as List<dynamic>? ?? [];
    return ChecklistRowEntity(
      id: json['id'] as int? ?? 0,
      serviceName: json['service_name'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      cells: cellsJson
          .map((dynamic item) => ChecklistCellEntity.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

