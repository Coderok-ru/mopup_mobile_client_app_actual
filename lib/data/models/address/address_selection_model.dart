import 'dart:convert';

import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Представляет выбранный пользователем адрес.
class AddressSelectionModel {
  /// Полный адрес в человекочитаемом формате.
  final String formattedAddress;

  /// Широта точки.
  final double latitude;

  /// Долгота точки.
  final double longitude;

  /// Создает модель выбранного адреса.
  const AddressSelectionModel({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  /// Возвращает точку для карты Yandex.
  Point get point => Point(latitude: latitude, longitude: longitude);

  /// Создает копию с новыми значениями.
  AddressSelectionModel copyWith({
    String? formattedAddress,
    double? latitude,
    double? longitude,
  }) {
    return AddressSelectionModel(
      formattedAddress: formattedAddress ?? this.formattedAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Преобразует в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'formattedAddress': formattedAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Преобразует в строку для хранения.
  String toJsonString() => jsonEncode(toJson());

  /// Создает экземпляр из JSON.
  factory AddressSelectionModel.fromJson(Map<String, dynamic> json) {
    return AddressSelectionModel(
      formattedAddress: json['formattedAddress'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Создает экземпляр из строки.
  factory AddressSelectionModel.fromJsonString(String source) {
    final Map<String, dynamic> data =
        jsonDecode(source) as Map<String, dynamic>;
    return AddressSelectionModel.fromJson(data);
  }
}
