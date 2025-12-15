import 'package:dio/dio.dart';

/// Описывает данные регистрации.
class RegistrationPayload {
  /// Имя.
  final String name;

  /// Фамилия.
  final String lastName;

  /// Телефон.
  final String phone;

  /// Электронная почта.
  final String email;

  /// Пароль.
  final String password;

  /// Подтверждение пароля.
  final String passwordConfirmation;

  /// Идентификатор города.
  final int cityId;

  /// Путь к файлу аватара.
  final String? avatarPath;

  /// Байты аватара.
  final List<int>? avatarBytes;

  /// Имя файла аватара.
  final String? avatarFileName;

  /// Создает полезную нагрузку.
  const RegistrationPayload({
    required this.name,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.cityId,
    this.avatarPath,
    this.avatarBytes,
    this.avatarFileName,
  });

  /// Создает тело multipart запроса.
  Future<FormData> createFormData() async {
    final Map<String, dynamic> data = <String, dynamic>{
      'name': name,
      'lname': lastName,
      'phone': phone,
      'email': email,
      'password': password,
      'passwordV': passwordConfirmation,
      'city': cityId,
    };
    if (avatarBytes != null &&
        avatarBytes!.isNotEmpty &&
        avatarFileName != null &&
        avatarFileName!.isNotEmpty) {
      data['profile_photo_path'] = MultipartFile.fromBytes(
        avatarBytes!,
        filename: avatarFileName!,
      );
    } else if (avatarPath != null && avatarPath!.isNotEmpty) {
      data['profile_photo_path'] = await MultipartFile.fromFile(avatarPath!);
    }
    return FormData.fromMap(data);
  }
}
