import 'package:dio/dio.dart';

/// Описывает данные обновления профиля.
class ProfileUpdatePayload {
  /// Имя.
  final String? name;

  /// Фамилия.
  final String? lastName;

  /// Электронная почта.
  final String? email;

  /// Телефон.
  final String? phone;

  /// Идентификатор города.
  final int? cityId;

  /// Путь к аватару.
  final String? avatarPath;

  /// Байты аватара.
  final List<int>? avatarBytes;

  /// Имя файла аватара.
  final String? avatarFileName;

  /// Создает полезную нагрузку.
  const ProfileUpdatePayload({
    this.name,
    this.lastName,
    this.email,
    this.phone,
    this.cityId,
    this.avatarPath,
    this.avatarBytes,
    this.avatarFileName,
  });

  /// Создает тело запроса.
  Future<dynamic> createBody() async {
    final Map<String, dynamic> data = <String, dynamic>{
      if (name != null && name!.isNotEmpty) 'name': name,
      if (lastName != null && lastName!.isNotEmpty) 'lname': lastName,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (cityId != null) 'city': cityId,
    };
    if (avatarBytes != null &&
        avatarBytes!.isNotEmpty &&
        avatarFileName != null &&
        avatarFileName!.isNotEmpty) {
      data['profile_photo_path'] = MultipartFile.fromBytes(
        avatarBytes!,
        filename: avatarFileName!,
      );
      return FormData.fromMap(data);
    }
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      data['profile_photo_path'] = await MultipartFile.fromFile(avatarPath!);
      return FormData.fromMap(data);
    }
    return data;
  }
}
