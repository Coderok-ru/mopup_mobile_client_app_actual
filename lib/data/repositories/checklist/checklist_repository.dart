import '../../models/checklist/checklist_entity.dart';

/// Контракты получения чек-листа.
abstract class ChecklistRepository {
  /// Загружает основной чек-лист.
  Future<ChecklistEntity> loadMainChecklist();
}

