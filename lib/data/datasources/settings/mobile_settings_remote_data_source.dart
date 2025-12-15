import 'package:dio/dio.dart';

import '../../../core/constants/app_urls.dart';
import '../../models/settings/mobile_settings_entity.dart';

/// Выполняет сетевые запросы для получения мобильных настроек.
class MobileSettingsRemoteDataSource {
  /// HTTP‑клиент.
  final Dio dio;

  /// Создает источник данных мобильных настроек.
  const MobileSettingsRemoteDataSource({required this.dio});

  /// Загружает мобильные настройки приложения.
  Future<MobileSettingsEntity> loadMobileSettings() async {
    final Response<dynamic> response =
        await dio.get<dynamic>(AppUrls.mobileSettings);
    final dynamic raw = response.data;
    if (raw is Map<String, dynamic>) {
      final dynamic payload = raw['data'] ?? raw;
      if (payload is Map<String, dynamic>) {
        return MobileSettingsEntity.fromJson(payload);
      }
    }
    throw Exception('Некорректный ответ сервера при загрузке мобильных настроек');
  }
}


