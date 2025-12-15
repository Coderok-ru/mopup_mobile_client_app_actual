import 'package:characters/characters.dart';

/// Описывает профиль пользователя.
class UserEntity {
  /// Идентификатор пользователя.
  final int id;

  /// Имя.
  final String name;

  /// Фамилия.
  final String lastName;

  /// Телефон.
  final String phone;

  /// Почта.
  final String email;

  /// Список ролей.
  final List<String> roles;

  /// URL аватара.
  final String? avatarUrl;

  /// Кредитные карты.
  final dynamic creditCards;

  /// Идентификатор города.
  final int? cityId;

  /// Текущее значение рейтинга.
  final double? rating;

  /// Дата последнего обновления в БД.
  final DateTime? updatedAt;

  /// Создает сущность пользователя.
  const UserEntity({
    required this.id,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.roles,
    required this.avatarUrl,
    required this.creditCards,
    this.cityId,
    this.rating,
    this.updatedAt,
  });

  /// Создает сущность из JSON.
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final List<String> extractedRoles =
        (json['roles'] as List<dynamic>? ?? <dynamic>[])
            .map(
              (dynamic item) =>
                  (item as Map<String, dynamic>)['name'] as String,
            )
            .toList();
    return UserEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      lastName: json['lname'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roles: extractedRoles,
      avatarUrl: json['profile_photo_url'] as String?,
      creditCards: json['credit_cards'],
      cityId: _extractCityId(json['city']),
      rating: _tryParseDouble(json['rating']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Преобразует сущность в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'lname': lastName,
      'phone': phone,
      'email': email,
      'roles': roles
          .map((String role) => <String, String>{'name': role})
          .toList(),
      'profile_photo_url': avatarUrl,
      'credit_cards': creditCards,
      if (cityId != null) 'city': cityId,
      if (rating != null) 'rating': rating,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Возвращает инициалы пользователя.
  String getInitials() {
    final String first = name.isNotEmpty ? name.characters.first : '';
    final String second = lastName.isNotEmpty ? lastName.characters.first : '';
    return '$first$second'.toUpperCase();
  }

  /// Возвращает полное имя.
  String getFullName() {
    return '$name $lastName'.trim();
  }

  static int? _extractCityId(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is Map<String, dynamic>) {
      final dynamic id = value['id'];
      if (id is int) {
        return id;
      }
    }
    return null;
  }

  static double? _tryParseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }
}
