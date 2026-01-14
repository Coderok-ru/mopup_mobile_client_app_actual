/// Модель ячейки таблицы чек-листа.
class ChecklistCellEntity {
  /// Идентификатор ячейки.
  final int? id;
  /// Идентификатор колонки.
  final int columnId;
  /// Название колонки.
  final String columnName;
  /// Тип колонки.
  final String columnType;
  /// Текстовое значение.
  final String? textValue;
  /// Булево значение.
  final bool? booleanValue;
  /// Числовое значение.
  final num? numberValue;
  /// Создает модель ячейки.
  const ChecklistCellEntity({
    this.id,
    required this.columnId,
    required this.columnName,
    required this.columnType,
    this.textValue,
    this.booleanValue,
    this.numberValue,
  });
  /// Создает модель из JSON.
  factory ChecklistCellEntity.fromJson(Map<String, dynamic> json) {
    return ChecklistCellEntity(
      id: json['id'] as int?,
      columnId: json['column_id'] as int? ?? 0,
      columnName: json['column_name'] as String? ?? '',
      columnType: json['column_type'] as String? ?? '',
      textValue: json['text_value'] as String?,
      booleanValue: json['boolean_value'] as bool?,
      numberValue: json['number_value'] as num?,
    );
  }
}

