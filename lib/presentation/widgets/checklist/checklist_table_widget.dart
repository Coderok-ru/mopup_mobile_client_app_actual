import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/checklist/checklist_cell_entity.dart';
import '../../../data/models/checklist/checklist_column_entity.dart';
import '../../../data/models/checklist/checklist_entity.dart';
import '../../../data/models/checklist/checklist_row_entity.dart';
import '../../../data/models/checklist/checklist_section_entity.dart';

/// Виджет таблицы чек-листа.
class ChecklistTableWidget extends StatelessWidget {
  /// Данные чек-листа.
  final ChecklistEntity checklist;
  /// Создает виджет таблицы чек-листа.
  const ChecklistTableWidget({super.key, required this.checklist});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (checklist.hasHeader) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  checklist.name,
                  style: AppTypography.createTitle24(AppColors.black),
                ),
                if (checklist.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    checklist.description,
                    style: AppTypography.createBody16(AppColors.grayMedium),
                  ),
                ],
              ],
            ),
          ),
        ],
        ...checklist.sections.map((ChecklistSectionEntity section) => _SectionWidget(
          section: section,
          columns: checklist.columns,
        )),
      ],
    );
  }
}

/// Виджет секции таблицы.
class _SectionWidget extends StatelessWidget {
  /// Секция таблицы.
  final ChecklistSectionEntity section;
  /// Колонки таблицы.
  final List<ChecklistColumnEntity> columns;
  /// Создает виджет секции.
  const _SectionWidget({required this.section, required this.columns});
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _parseColor(section.backgroundColor);
    final List<ChecklistColumnEntity> serviceColumns = columns.where((ChecklistColumnEntity col) => col.type != 'text').toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              section.name,
              style: AppTypography.createTitle20(AppColors.black),
            ),
          ),
          _buildTableHeader(serviceColumns),
          ...section.rows.map((ChecklistRowEntity row) => _RowWidget(
            row: row,
            columns: columns,
            backgroundColor: backgroundColor,
          )),
        ],
      ),
    );
  }

  Widget _buildTableHeader(List<ChecklistColumnEntity> serviceColumns) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grayLight.withOpacity(0.5), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Table(
        columnWidths: <int, TableColumnWidth>{
          0: const FlexColumnWidth(2),
          ...Map<int, TableColumnWidth>.fromEntries(
            List<int>.generate(serviceColumns.length, (int i) => i + 1).map(
              (int index) => MapEntry<int, TableColumnWidth>(
                index,
                const FlexColumnWidth(1),
              ),
            ),
          ),
        },
        children: <TableRow>[
          TableRow(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Услуга',
                  style: AppTypography.createBody16(AppColors.grayDark).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ),
              ...serviceColumns.map((ChecklistColumnEntity column) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    column.name,
                    style: AppTypography.createBody16(AppColors.grayDark).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.white;
    }
  }
}

/// Виджет строки таблицы.
class _RowWidget extends StatelessWidget {
  /// Строка таблицы.
  final ChecklistRowEntity row;
  /// Колонки таблицы.
  final List<ChecklistColumnEntity> columns;
  /// Цвет фона секции.
  final Color backgroundColor;
  /// Создает виджет строки.
  const _RowWidget({
    required this.row,
    required this.columns,
    required this.backgroundColor,
  });
  @override
  Widget build(BuildContext context) {
    final List<ChecklistColumnEntity> serviceColumns = columns.where((ChecklistColumnEntity col) => col.type != 'text').toList();
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.grayLight.withOpacity(0.3)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Table(
        columnWidths: <int, TableColumnWidth>{
          0: const FlexColumnWidth(2),
          ...Map<int, TableColumnWidth>.fromEntries(
            List<int>.generate(serviceColumns.length, (int i) => i + 1).map(
              (int index) => MapEntry<int, TableColumnWidth>(
                index,
                const FlexColumnWidth(1),
              ),
            ),
          ),
        },
        children: <TableRow>[
          TableRow(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  row.serviceName,
                  style: AppTypography.createBody16(AppColors.black).copyWith(
                    fontSize: 10,
                  ),
                ),
              ),
              ...serviceColumns.map((ChecklistColumnEntity column) {
                final ChecklistCellEntity? cell = _findCellByColumnId(column.id);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _CellWidget(
                    cell: cell,
                    column: column,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  ChecklistCellEntity? _findCellByColumnId(int columnId) {
    try {
      return row.cells.firstWhere((ChecklistCellEntity cell) => cell.columnId == columnId);
    } catch (_) {
      return null;
    }
  }
}

/// Виджет ячейки таблицы.
class _CellWidget extends StatelessWidget {
  /// Ячейка таблицы.
  final ChecklistCellEntity? cell;
  /// Колонка таблицы.
  final ChecklistColumnEntity column;
  /// Создает виджет ячейки.
  const _CellWidget({this.cell, required this.column});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildCellValue(),
    );
  }

  Widget _buildCellValue() {
    if (cell == null) {
      return const SizedBox.shrink();
    }
    if (cell!.booleanValue == true) {
      if (cell!.textValue == 'included') {
        return const Icon(Icons.check, color: Color(0xFF5A8A4A), size: 20);
      }
      if (cell!.textValue == 'additional') {
        return Text(
          '₽',
          style: AppTypography.createBody16(AppColors.grayDark).copyWith(
            fontSize: 18,
          ),
        );
      }
      return const Icon(Icons.check, color: Color(0xFF5A8A4A), size: 20);
    }
    if (cell!.textValue != null && cell!.textValue!.isNotEmpty && cell!.textValue != 'included' && cell!.textValue != 'additional') {
      return Text(
        cell!.textValue!,
        style: AppTypography.createBody16(AppColors.black).copyWith(
          fontSize: 8,
        ),
        textAlign: TextAlign.center,
      );
    }
    return const SizedBox.shrink();
  }
}

