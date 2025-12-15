import 'user_entity.dart';

/// Описывает авторизованного пользователя и токен.
class AuthSessionEntity {
  /// Токен доступа.
  final String token;

  /// Пользователь.
  final UserEntity user;

  /// Создает сущность сессии.
  const AuthSessionEntity({required this.token, required this.user});

  /// Создает сущность из JSON.
  factory AuthSessionEntity.fromJson(Map<String, dynamic> json) {
    return AuthSessionEntity(
      token: json['token'] as String,
      user: UserEntity.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Преобразует сущность в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'token': token, 'user': user.toJson()};
  }
}
