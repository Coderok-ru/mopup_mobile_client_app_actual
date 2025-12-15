/// Описывает мобильные настройки приложения, получаемые с сервера.
class MobileSettingsEntity {
  /// Идентификатор записи настроек.
  final int id;

  /// HTML‑описание информации об услугах.
  final String info;

  /// Путь к логотипу.
  final String logo;

  /// HTML‑текст оферты.
  final String offer;

  /// Описание рейтинга и правил его изменения.
  final String rating;

  /// Дата создания записи.
  final DateTime createdAt;

  /// Дата обновления записи.
  final DateTime updatedAt;

  /// Версия приложения, для которой актуальны настройки.
  final String versionApp;

  /// Создает сущность мобильных настроек.
  const MobileSettingsEntity({
    required this.id,
    required this.info,
    required this.logo,
    required this.offer,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.versionApp,
  });

  /// Создает сущность из JSON‑объекта.
  factory MobileSettingsEntity.fromJson(Map<String, dynamic> json) {
    return MobileSettingsEntity(
      id: json['id'] as int? ?? 0,
      info: json['info'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      offer: json['offer'] as String? ?? '',
      rating: json['rating'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      versionApp: json['version_app'] as String? ?? '',
    );
  }
}


