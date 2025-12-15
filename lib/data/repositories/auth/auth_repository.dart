import '../../models/auth/auth_session_entity.dart';
import '../../models/auth/city_entity.dart';
import '../../models/auth/user_entity.dart';
import '../../models/auth/login_payload.dart';
import '../../models/auth/profile_update_payload.dart';
import '../../models/auth/registration_payload.dart';

/// Контракты авторизации.
abstract class AuthRepository {
  /// Загружает доступные города.
  Future<List<CityEntity>> loadCities();

  /// Регистрирует пользователя.
  Future<AuthSessionEntity> register(RegistrationPayload payload);

  /// Авторизует пользователя.
  Future<AuthSessionEntity> login(LoginPayload payload);

  /// Возвращает профиль.
  Future<UserEntity> loadProfile();

  /// Обновляет профиль.
  Future<UserEntity> updateProfile(ProfileUpdatePayload payload);

  /// Выходит из профиля.
  Future<void> logout();

  /// Удаляет аккаунт.
  Future<void> deleteAccount();

  /// Сохраняет сессию.
  Future<void> saveSession(AuthSessionEntity session);

  /// Загружает сохраненную сессию.
  AuthSessionEntity? readSession();

  /// Очищает все данные.
  Future<void> clearSession();

  /// Сохраняет токен.
  Future<void> saveToken(String token);

  /// Загружает токен.
  String? readToken();

  /// Отправляет данные устройства для push-уведомлений.
  Future<void> sendPlayerId({
    required String deviceToken,
    required String platform,
  });
}
