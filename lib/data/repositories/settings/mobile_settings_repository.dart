import '../../models/settings/mobile_settings_entity.dart';

/// Контракты получения мобильных настроек.
abstract class MobileSettingsRepository {
  /// Загружает мобильные настройки приложения.
  Future<MobileSettingsEntity> loadMobileSettings();
}


