import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../../../core/constants/storage_keys.dart';
import '../../models/auth/auth_session_entity.dart';

/// Работает с локальным хранилищем авторизации.
class AuthLocalDataSource {
  /// Экземпляр хранилища.
  final GetStorage storage;

  /// Создает источник локальных данных.
  AuthLocalDataSource({required this.storage});

  /// Сохраняет сессию.
  Future<void> saveSession(AuthSessionEntity session) {
    final String sessionJson = jsonEncode(session.toJson());
    return storage.write(StorageKeys.authUser, sessionJson);
  }

  /// Загружает сессию.
  AuthSessionEntity? loadSession() {
    final String? raw = storage.read<String>(StorageKeys.authUser);
    if (raw == null) {
      return null;
    }
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    return AuthSessionEntity.fromJson(json);
  }

  /// Сохраняет токен.
  Future<void> saveToken(String token) {
    return storage.write(StorageKeys.authToken, token);
  }

  /// Получает токен.
  String? loadToken() {
    return storage.read<String>(StorageKeys.authToken);
  }

  /// Очищает данные.
  Future<void> clear() {
    return storage.erase();
  }
}
