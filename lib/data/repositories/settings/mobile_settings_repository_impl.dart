import '../../datasources/settings/mobile_settings_remote_data_source.dart';
import '../../models/settings/mobile_settings_entity.dart';
import 'mobile_settings_repository.dart';

/// Репозиторий мобильных настроек, работающий через REST API.
class MobileSettingsRepositoryImpl implements MobileSettingsRepository {
  /// Удаленный источник данных.
  final MobileSettingsRemoteDataSource remoteDataSource;

  /// Создает репозиторий мобильных настроек.
  const MobileSettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MobileSettingsEntity> loadMobileSettings() {
    return remoteDataSource.loadMobileSettings();
  }
}


