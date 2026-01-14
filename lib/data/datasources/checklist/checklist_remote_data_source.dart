import 'package:dio/dio.dart';
import '../../../core/constants/app_urls.dart';
import '../../models/checklist/checklist_entity.dart';

/// Выполняет сетевые запросы для получения чек-листа.
class ChecklistRemoteDataSource {
  /// HTTP‑клиент.
  final Dio dio;
  /// Создает источник данных чек-листа.
  const ChecklistRemoteDataSource({required this.dio});
  /// Загружает основной чек-лист.
  Future<ChecklistEntity> loadMainChecklist() async {
    final Response<dynamic> response = await dio.get<dynamic>(AppUrls.checklistsMain);
    final dynamic raw = response.data;
    if (raw is Map<String, dynamic>) {
      final dynamic payload = raw['data'] ?? raw;
      if (payload is Map<String, dynamic>) {
        return ChecklistEntity.fromJson(payload);
      }
    }
    throw Exception('Некорректный ответ сервера при загрузке чек-листа');
  }
}

