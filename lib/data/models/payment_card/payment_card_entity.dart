/// Описывает банковскую карту клиента.
class PaymentCardEntity {
  /// Идентификатор карты.
  final int id;

  /// Маскированный номер карты.
  final String maskedPan;

  /// Последние четыре цифры.
  final String? lastFour;

  /// Платёжная система.
  final String? brand;

  /// Имя владельца карты.
  final String? holderName;

  /// Месяц окончания срока действия.
  final int? expMonth;

  /// Год окончания срока действия.
  final int? expYear;

  /// Признак карты по умолчанию.
  final bool isDefault;

  /// Дата создания записи.
  final DateTime? createdAt;

  /// Дата обновления записи.
  final DateTime? updatedAt;

  /// Создает сущность банковской карты.
  const PaymentCardEntity({
    required this.id,
    required this.maskedPan,
    required this.isDefault,
    this.lastFour,
    this.brand,
    this.holderName,
    this.expMonth,
    this.expYear,
    this.createdAt,
    this.updatedAt,
  });

  /// Создает сущность из JSON.
  factory PaymentCardEntity.fromJson(Map<String, dynamic> json) {
    return PaymentCardEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      maskedPan: json['masked_pan']?.toString() ?? '',
      lastFour: json['last_four']?.toString(),
      brand: json['brand']?.toString(),
      holderName: json['holder_name']?.toString(),
      expMonth: _tryParseInt(json['exp_month']),
      expYear: _tryParseInt(json['exp_year']),
      isDefault: json['is_default'] == true ||
          json['is_default']?.toString() == '1',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Преобразует сущность в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'masked_pan': maskedPan,
      if (lastFour != null) 'last_four': lastFour,
      if (brand != null) 'brand': brand,
      if (holderName != null) 'holder_name': holderName,
      if (expMonth != null) 'exp_month': expMonth,
      if (expYear != null) 'exp_year': expYear,
      'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Возвращает копию сущности с изменёнными полями.
  PaymentCardEntity copyWith({
    bool? isDefault,
  }) {
    return PaymentCardEntity(
      id: id,
      maskedPan: maskedPan,
      lastFour: lastFour,
      brand: brand,
      holderName: holderName,
      expMonth: expMonth,
      expYear: expYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static int? _tryParseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
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


