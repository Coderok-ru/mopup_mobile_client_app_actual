/// Модель данных для экрана подтверждения заказа.
class OrderConfirmationViewModel {
  /// Имя клиента.
  final String customerName;

  /// Телефон клиента.
  final String customerPhone;

  /// Идентификатор пользователя.
  final int? userId;

  /// Идентификатор шаблона.
  final int? templateId;

  /// Идентификатор города.
  final int? cityId;

  /// Форматированная дата уборки.
  final String formattedDate;

  /// Форматированное время уборки.
  final String formattedTime;

  /// Полный адрес.
  final String address;

  /// Номер квартиры или домофона.
  final String doorCode;

  /// Широта.
  final double? latitude;

  /// Долгота.
  final double? longitude;

  /// Стоимость базовых услуг.
  final double basePrice;

  /// Стоимость дополнительных услуг.
  final double additionalPrice;

  /// Итоговая стоимость заказа.
  final double totalPrice;

  /// Итоговое время уборки в минутах.
  final int totalTimeMinutes;

  /// Payload запроса.
  final Map<String, dynamic> payload;

  /// JSON-представление payload.
  final String jsonPayload;

  /// Создает модель данных.
  const OrderConfirmationViewModel({
    required this.customerName,
    required this.customerPhone,
    required this.userId,
    required this.templateId,
    required this.cityId,
    required this.formattedDate,
    required this.formattedTime,
    required this.address,
    required this.doorCode,
    required this.latitude,
    required this.longitude,
    required this.basePrice,
    required this.additionalPrice,
    required this.totalPrice,
    required this.totalTimeMinutes,
    required this.payload,
    required this.jsonPayload,
  });
}
