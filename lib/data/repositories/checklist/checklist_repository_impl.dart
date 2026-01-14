import '../../datasources/checklist/checklist_remote_data_source.dart';
import '../../models/checklist/checklist_entity.dart';
import 'checklist_repository.dart';

/// Репозиторий чек-листа, работающий через REST API.
class ChecklistRepositoryImpl implements ChecklistRepository {
  /// Удаленный источник данных.
  final ChecklistRemoteDataSource remoteDataSource;
  /// Создает репозиторий чек-листа.
  const ChecklistRepositoryImpl({required this.remoteDataSource});
  @override
  Future<ChecklistEntity> loadMainChecklist() {
    return remoteDataSource.loadMainChecklist();
  }
}

