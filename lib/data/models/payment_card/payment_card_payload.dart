/// Данные для создания новой банковской карты.
class PaymentCardPayload {
  /// Токен карты платёжного провайдера.
  final String? cardToken;

  /// Идентификатор карты у платёжного провайдера.
  final String? cardId;

  /// Маскированный номер карты.
  final String maskedPan;

  /// Последние четыре цифры.
  final String? lastFour;

  /// Платёжная система.
  final String? brand;

  /// Имя владельца.
  final String? holderName;

  /// Месяц окончания срока действия.
  final int? expMonth;

  /// Год окончания срока действия.
  final int? expYear;

  /// Признак карты по умолчанию.
  final bool isDefault;

  /// Создает payload для отправки на сервер.
  const PaymentCardPayload({
    this.cardToken,
    this.cardId,
    required this.maskedPan,
    this.lastFour,
    this.brand,
    this.holderName,
    this.expMonth,
    this.expYear,
    this.isDefault = false,
  });

  /// Преобразует payload в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (cardId != null) 'card_id': cardId,
      if (cardToken != null) 'card_token': cardToken,
      'masked_pan': maskedPan,
      if (lastFour != null) 'last_four': lastFour,
      if (brand != null) 'brand': brand,
      if (holderName != null) 'holder_name': holderName,
      if (expMonth != null) 'exp_month': expMonth,
      if (expYear != null) 'exp_year': expYear,
      'is_default': isDefault,
    };
  }
}


