/// Описывает данные для авторизации.
class LoginPayload {
  /// Телефон.
  final String phone;

  /// Пароль.
  final String password;

  /// Токен устройства.
  final String? deviceToken;

  /// Создает полезную нагрузку.
  const LoginPayload({
    required this.phone,
    required this.password,
    this.deviceToken,
  });

  /// Преобразует в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phone': phone,
      'password': password,
      if (deviceToken != null && deviceToken!.isNotEmpty)
        'device_token': deviceToken,
    };
  }
}
