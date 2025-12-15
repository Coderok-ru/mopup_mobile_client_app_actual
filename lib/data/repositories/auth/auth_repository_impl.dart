import '../../datasources/auth/auth_local_data_source.dart';
import '../../datasources/auth/auth_remote_data_source.dart';
import '../../models/auth/auth_session_entity.dart';
import '../../models/auth/city_entity.dart';
import '../../models/auth/user_entity.dart';
import '../../models/auth/login_payload.dart';
import '../../models/auth/profile_update_payload.dart';
import '../../models/auth/registration_payload.dart';
import 'auth_repository.dart';

/// Реализация репозитория авторизации.
class AuthRepositoryImpl implements AuthRepository {
  /// Удаленный источник.
  final AuthRemoteDataSource remoteDataSource;

  /// Локальный источник.
  final AuthLocalDataSource localDataSource;

  /// Создает репозиторий.
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<CityEntity>> loadCities() {
    return remoteDataSource.loadCities();
  }

  @override
  Future<AuthSessionEntity> register(RegistrationPayload payload) async {
    final AuthSessionEntity session = await remoteDataSource.register(payload);
    await localDataSource.saveSession(session);
    await localDataSource.saveToken(session.token);
    return session;
  }

  @override
  Future<AuthSessionEntity> login(LoginPayload payload) async {
    final AuthSessionEntity session = await remoteDataSource.login(payload);
    await localDataSource.saveSession(session);
    await localDataSource.saveToken(session.token);
    return session;
  }

  @override
  Future<UserEntity> loadProfile() {
    return remoteDataSource.loadProfile();
  }

  @override
  Future<UserEntity> updateProfile(ProfileUpdatePayload payload) async {
    final UserEntity user = await remoteDataSource.updateProfile(payload);
    final AuthSessionEntity? current = readSession();
    if (current != null) {
      final AuthSessionEntity updated = AuthSessionEntity(
        token: current.token,
        user: user,
      );
      await saveSession(updated);
    }
    return user;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await clearSession();
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.deleteAccount();
    await clearSession();
  }

  @override
  Future<void> saveSession(AuthSessionEntity session) async {
    await localDataSource.saveSession(session);
    await localDataSource.saveToken(session.token);
  }

  @override
  AuthSessionEntity? readSession() {
    return localDataSource.loadSession();
  }

  @override
  Future<void> clearSession() async {
    await localDataSource.clear();
  }

  @override
  Future<void> saveToken(String token) {
    return localDataSource.saveToken(token);
  }

  @override
  String? readToken() {
    return localDataSource.loadToken();
  }

  @override
  Future<void> sendPlayerId({
    required String deviceToken,
    required String platform,
  }) {
    return remoteDataSource.sendPlayerId(
      deviceToken: deviceToken,
      platform: platform,
    );
  }
}
