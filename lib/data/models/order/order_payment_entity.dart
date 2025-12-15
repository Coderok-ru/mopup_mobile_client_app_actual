/// Модель платежа заказа.
class OrderPaymentEntity {
  /// Идентификатор платежа.
  final int id;

  /// Идентификатор заказа.
  final int orderId;

  /// Идентификатор платежа в платежной системе.
  final String? paymentId;

  /// URL для оплаты.
  final String? paymentUrl;

  /// Сумма платежа в копейках.
  final int amount;

  /// Статус платежа (NEW, paid, и т.д.).
  final String status;

  /// Описание платежа.
  final String? description;

  /// Данные карты клиента.
  final dynamic cardClient;

  /// Данные запроса на оплату.
  final Map<String, dynamic>? requestData;

  /// Данные ответа от платежной системы.
  final Map<String, dynamic>? responseData;

  /// Идентификатор платежа клинера.
  final int? cleanerPaymentId;

  /// Статус платежа клинера.
  final String? cleanerStatus;

  /// Сумма платежа клинера.
  final int? cleanerAmount;

  /// URL карты клинера.
  final String? cleanerCardUrl;

  /// Данные карты.
  final dynamic cardData;

  /// Идентификатор накопления SP.
  final int? spAccumulationId;

  /// Дата создания.
  final String createdAt;

  /// Дата обновления.
  final String updatedAt;

  /// Дата оплаты клинером.
  final String? cleanerPaidAt;

  /// Создает сущность платежа заказа.
  const OrderPaymentEntity({
    required this.id,
    required this.orderId,
    this.paymentId,
    this.paymentUrl,
    required this.amount,
    required this.status,
    this.description,
    this.cardClient,
    this.requestData,
    this.responseData,
    this.cleanerPaymentId,
    this.cleanerStatus,
    this.cleanerAmount,
    this.cleanerCardUrl,
    this.cardData,
    this.spAccumulationId,
    required this.createdAt,
    required this.updatedAt,
    this.cleanerPaidAt,
  });

  /// Создает сущность из JSON.
  factory OrderPaymentEntity.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int? ?? 0;
    final int orderId = json['order_id'] as int? ?? 0;
    final String? paymentId = json['payment_id'] as String?;
    final String? paymentUrl = json['payment_url'] as String?;
    final int amount = _readAmount(json);
    final String status = (json['status'] as String? ?? '').trim();
    final String? description = json['description'] as String?;
    final dynamic cardClient = json['card_client'];
    Map<String, dynamic>? requestData;
    if (json['request_data'] is Map<String, dynamic>) {
      requestData = json['request_data'] as Map<String, dynamic>;
    }
    Map<String, dynamic>? responseData;
    if (json['response_data'] is Map<String, dynamic>) {
      responseData = json['response_data'] as Map<String, dynamic>;
    }
    final int? cleanerPaymentId = json['cleaner_payment_id'] as int?;
    final String? cleanerStatus = json['cleaner_status'] as String?;
    final int? cleanerAmount = json['cleaner_amount'] as int?;
    final String? cleanerCardUrl = json['cleaner_card_url'] as String?;
    final dynamic cardData = json['card_data'];
    final int? spAccumulationId = json['sp_accumulation_id'] as int?;
    final String createdAt = json['created_at'] as String? ?? '';
    final String updatedAt = json['updated_at'] as String? ?? '';
    final String? cleanerPaidAt = json['cleaner_paid_at'] as String?;
    return OrderPaymentEntity(
      id: id,
      orderId: orderId,
      paymentId: paymentId,
      paymentUrl: paymentUrl,
      amount: amount,
      status: status,
      description: description,
      cardClient: cardClient,
      requestData: requestData,
      responseData: responseData,
      cleanerPaymentId: cleanerPaymentId,
      cleanerStatus: cleanerStatus,
      cleanerAmount: cleanerAmount,
      cleanerCardUrl: cleanerCardUrl,
      cardData: cardData,
      spAccumulationId: spAccumulationId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cleanerPaidAt: cleanerPaidAt,
    );
  }

  /// Преобразует сущность платежа в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'order_id': orderId,
      if (paymentId != null) 'payment_id': paymentId,
      if (paymentUrl != null) 'payment_url': paymentUrl,
      'amount': amount,
      'status': status,
      if (description != null) 'description': description,
      if (cardClient != null) 'card_client': cardClient,
      if (requestData != null) 'request_data': requestData,
      if (responseData != null) 'response_data': responseData,
      if (cleanerPaymentId != null) 'cleaner_payment_id': cleanerPaymentId,
      if (cleanerStatus != null) 'cleaner_status': cleanerStatus,
      if (cleanerAmount != null) 'cleaner_amount': cleanerAmount,
      if (cleanerCardUrl != null) 'cleaner_card_url': cleanerCardUrl,
      if (cardData != null) 'card_data': cardData,
      if (spAccumulationId != null) 'sp_accumulation_id': spAccumulationId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (cleanerPaidAt != null) 'cleaner_paid_at': cleanerPaidAt,
    };
  }

  /// Возвращает сумму в рублях.
  double get amountInRubles {
    return amount / 100.0;
  }

  /// Проверяет, оплачен ли заказ.
  bool get isPaid {
    return status.toLowerCase() == 'paid';
  }

  static int _readAmount(Map<String, dynamic> json) {
    final dynamic value = json['amount'];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }
}

