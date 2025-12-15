import 'order_payment_entity.dart';

/// Модель заказа.
class OrderEntity {
  /// Идентификатор заказа.
  final int id;

  /// Тип заказа (single или multy).
  final String orderType;

  /// Идентификатор статуса.
  final int statusId;

  /// Общая стоимость.
  final double totalPrice;

  /// Дата и время заказа.
  final String dateTime;

  /// Город.
  final OrderCityEntity? city;

  /// Статус.
  final OrderStatusEntity? status;

  /// Дополнительные даты для подписок (multy-заказов).
  final List<OrderDateEntity> orderDates;

  /// Название шаблона заказа.
  final String templateName;

  /// Адрес заказа.
  final String address;

  /// Номер квартиры/офиса.
  final String? addressApartment;

  /// Дата заказа (формат `дд.мм.гггг`).
  final String orderDate;

  /// Время заказа (формат `чч:мм`).
  final String orderTime;

  /// Код заказа для пользователя.
  final String userCode;

  /// Имя клинера (если назначен).
  final String? cleanerName;

  /// Идентификатор клинера.
  final int? cleanerId;

  /// Платеж заказа.
  final OrderPaymentEntity? payment;

  /// Создает сущность заказа.
  const OrderEntity({
    required this.id,
    required this.orderType,
    required this.statusId,
    required this.totalPrice,
    required this.dateTime,
    this.city,
    this.status,
    this.orderDates = const <OrderDateEntity>[],
    this.templateName = '',
    this.address = '',
    this.addressApartment,
    this.orderDate = '',
    this.orderTime = '',
    this.userCode = '',
    this.cleanerName,
    this.cleanerId,
    this.payment,
  });

  /// Создает сущность из JSON.
  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    final int id = _readId(json);
    final String orderType = json['order_type'] as String? ?? 'single';
    final int statusId = json['status_id'] as int? ?? 0;
    final double totalPrice = _readDouble(json, 'total_price');
    final String dateTime = json['date_time'] as String? ?? '';
    OrderCityEntity? city;
    if (json['city'] != null && json['city'] is Map<String, dynamic>) {
      try {
        city = OrderCityEntity.fromJson(
          json['city'] as Map<String, dynamic>,
        );
      } catch (e) {
        print('Ошибка парсинга city: $e');
      }
    }
    OrderStatusEntity? status;
    if (json['status'] != null && json['status'] is Map<String, dynamic>) {
      try {
        status = OrderStatusEntity.fromJson(
          json['status'] as Map<String, dynamic>,
        );
      } catch (e) {
        print('Ошибка парсинга status: $e');
      }
    }
    List<OrderDateEntity> orderDates = <OrderDateEntity>[];
    if (json['orderDates'] != null && json['orderDates'] is List<dynamic>) {
      try {
        orderDates = (json['orderDates'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> item) => OrderDateEntity.fromJson(item))
            .toList();
      } catch (e) {
        print('Ошибка парсинга orderDates: $e');
      }
    }
    OrderPaymentEntity? payment;
    if (json['payment'] != null && json['payment'] is Map<String, dynamic>) {
      try {
        payment = OrderPaymentEntity.fromJson(
          json['payment'] as Map<String, dynamic>,
        );
      } catch (e) {
        print('Ошибка парсинга payment: $e');
      }
    }
    return OrderEntity(
      id: id,
      orderType: orderType,
      statusId: statusId,
      totalPrice: totalPrice,
      dateTime: dateTime,
      city: city,
      status: status,
      orderDates: orderDates,
      templateName: _readTemplateName(json),
      address: _readAddress(json),
      addressApartment: json['address_kv'] as String?,
      orderDate: json['dates'] as String? ?? '',
      orderTime: json['times'] as String? ?? '',
      userCode: json['user_url'] as String? ?? '',
      cleanerName: _readCleanerName(json),
      cleanerId: json['cleaner_id'] as int?,
      payment: payment,
    );
  }

  /// Преобразует сущность заказа в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'order_type': orderType,
      'status_id': statusId,
      'total_price': totalPrice,
      'date_time': dateTime,
      if (city != null) 'city': city!.toJson(),
      if (status != null) 'status': status!.toJson(),
      'orderDates':
          orderDates.map((OrderDateEntity item) => item.toJson()).toList(),
      'template_name': templateName,
      'address_address': address,
      if (addressApartment != null) 'address_kv': addressApartment,
      'dates': orderDate,
      'times': orderTime,
      'user_url': userCode,
      if (cleanerName != null) 'cleaner_name': cleanerName,
      if (cleanerId != null) 'cleaner_id': cleanerId,
      if (payment != null) 'payment': payment!.toJson(),
    };
  }

  static int _readId(Map<String, dynamic> json) {
    final dynamic value = json['id'];
    if (value is int) {
      return value;
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  static double _readDouble(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return 0.0;
  }

  static String _readAddress(Map<String, dynamic> json) {
    final String? address = json['address_address'] as String?;
    if (address == null || address.trim().isEmpty) {
      return 'Адрес не указан';
    }
    return address.trim();
  }

  static String? _readCleanerName(Map<String, dynamic> json) {
    if (json['cleaner'] is Map<String, dynamic>) {
      final Map<String, dynamic> cleaner =
          json['cleaner'] as Map<String, dynamic>;
      final String firstName =
          (cleaner['name'] as String? ?? '').trim();
      final String lastName =
          (cleaner['lname'] as String? ??
                  cleaner['surname'] as String? ??
                  cleaner['last_name'] as String? ??
                  '')
              .trim();
      if (firstName.isEmpty && lastName.isEmpty) {
        return null;
      }
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName.isNotEmpty ? firstName : lastName;
    }
    return null;
  }

  static String _readTemplateName(Map<String, dynamic> json) {
    if (json['template'] is Map<String, dynamic>) {
      final Map<String, dynamic> template = json['template'] as Map<String, dynamic>;
      final String? name = template['name'] as String?;
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }
    final String? directName = json['template_name'] as String?;
    if (directName != null && directName.trim().isNotEmpty) {
      return directName.trim();
    }
    return 'Заказ';
  }
}

/// Модель города заказа.
class OrderCityEntity {
  /// Идентификатор города.
  final int id;

  /// Название города.
  final String name;

  /// Создает сущность города.
  const OrderCityEntity({
    required this.id,
    required this.name,
  });

  /// Создает сущность из JSON.
  factory OrderCityEntity.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int? ?? 0;
    final String name = json['name'] as String? ?? '';
    return OrderCityEntity(id: id, name: name);
  }

  /// Преобразует сущность города в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }
}

/// Модель статуса заказа.
class OrderStatusEntity {
  /// Идентификатор статуса.
  final int id;

  /// Название статуса.
  final String name;

  /// Создает сущность статуса.
  const OrderStatusEntity({
    required this.id,
    required this.name,
  });

  /// Создает сущность из JSON.
  factory OrderStatusEntity.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int? ?? 0;
    final String name = json['name'] as String? ?? '';
    return OrderStatusEntity(id: id, name: name);
  }

  /// Преобразует сущность статуса в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }
}

/// Модель дополнительной даты заказа (для подписок).
class OrderDateEntity {
  /// Идентификатор записи.
  final int id;

  /// Связь с заказом.
  final int orderId;

  /// Запланированная дата.
  final String scheduledDate;

  /// Запланированное время.
  final String scheduledTime;

  /// Полный datetime.
  final String? dateTime;

  /// Статус визита.
  final String status;

  /// Создает сущность дополнительной даты заказа.
  const OrderDateEntity({
    required this.id,
    required this.orderId,
    required this.scheduledDate,
    required this.scheduledTime,
    this.dateTime,
    required this.status,
  });

  /// Создает сущность из JSON.
  factory OrderDateEntity.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int? ?? 0;
    final int orderId = json['order_id'] as int? ?? 0;
    final String scheduledDate = json['scheduled_date'] as String? ?? '';
    final String scheduledTime = json['scheduled_time'] as String? ?? '';
    final String? dateTime = json['date_time'] as String?;
    final String status = json['status'] as String? ?? 'pending';
    return OrderDateEntity(
      id: id,
      orderId: orderId,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      dateTime: dateTime,
      status: status,
    );
  }

  /// Преобразует сущность дополнительной даты в JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'order_id': orderId,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      if (dateTime != null) 'date_time': dateTime,
      'status': status,
    };
  }
}

