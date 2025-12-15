import 'package:dio/dio.dart';

import '../../../core/constants/app_urls.dart';
import '../../models/auth/auth_session_entity.dart';
import '../../models/auth/city_entity.dart';
import '../../models/auth/user_entity.dart';
import '../../models/auth/login_payload.dart';
import '../../models/auth/profile_update_payload.dart';
import '../../models/auth/registration_payload.dart';

/// Выполняет сетевые запросы авторизации.
class AuthRemoteDataSource {
  /// HTTP клиент.
  final Dio dio;

  /// Создает удаленный источник данных.
  AuthRemoteDataSource({required this.dio});

  /// Загружает города.
  Future<List<CityEntity>> loadCities() async {
    final Response<dynamic> response = await dio.get<dynamic>(AppUrls.cities);
    final List<dynamic> list = response.data as List<dynamic>;
    return list
        .map(
          (dynamic item) => CityEntity.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Регистрирует пользователя.
  Future<AuthSessionEntity> register(RegistrationPayload payload) async {
    final FormData formData = await payload.createFormData();
    final Response<dynamic> response = await dio.post<dynamic>(
      AppUrls.register,
      data: formData,
    );
    return AuthSessionEntity.fromJson(response.data as Map<String, dynamic>);
  }

  /// Авторизует пользователя.
  Future<AuthSessionEntity> login(LoginPayload payload) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      AppUrls.login,
      data: payload.toJson(),
    );
    return AuthSessionEntity.fromJson(response.data as Map<String, dynamic>);
  }

  /// Загружает профиль.
  Future<UserEntity> loadProfile() async {
    final Response<dynamic> response = await dio.get<dynamic>(AppUrls.profile);
    return UserEntity.fromJson(
      (response.data as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
  }

  /// Обновляет профиль.
  Future<UserEntity> updateProfile(ProfileUpdatePayload payload) async {
    final dynamic body = await payload.createBody();
    Response<dynamic> response;
    if (body is FormData) {
      body.fields.add(const MapEntry<String, String>('_method', 'PUT'));
      response = await dio.post<dynamic>(AppUrls.updateProfile, data: body);
    } else {
      response = await dio.put<dynamic>(AppUrls.updateProfile, data: body);
    }
    return UserEntity.fromJson(
      (response.data as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
  }

  /// Выходит из аккаунта.
  Future<void> logout() {
    return dio.post<dynamic>(AppUrls.logout);
  }

  /// Удаляет аккаунт.
  Future<void> deleteAccount() {
    return dio.delete<dynamic>(AppUrls.deleteAccount);
  }

  /// Отправляет данные устройства для push-уведомлений.
  Future<void> sendPlayerId({
    required String deviceToken,
    required String platform,
  }) async {
    try {
      await dio.put<dynamic>(
        AppUrls.playerId,
        data: <String, dynamic>{
          'device_token': deviceToken,
          'avatar': platform,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 405) {
        await dio.patch<dynamic>(
          AppUrls.playerId,
          data: <String, dynamic>{
            'device_token': deviceToken,
            'avatar': platform,
          },
        );
      } else {
        rethrow;
      }
    }
  }
}
