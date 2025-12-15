import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/payment_status_utils.dart';
import '../../data/models/order/order_entity.dart';
import '../../data/repositories/order/order_repository.dart';
import '../../data/repositories/favorite_cleaner/favorite_cleaner_repository.dart';

/// Контроллер экрана деталей заказа.
class OrderDetailsController extends GetxController {
  /// Репозиторий заказов.
  final OrderRepository orderRepository;

  /// Репозиторий любимых клинеров.
  final FavoriteCleanerRepository favoriteCleanerRepository;

  /// Заказ, переданный из списка.
  late final OrderEntity order;

  /// Состояние загрузки деталей.
  final RxBool isLoading = false.obs;

  /// Сообщение об ошибке.
  final RxnString errorMessage = RxnString();

  /// Список текстов базовых услуг.
  final RxList<String> baseServicesTexts = <String>[].obs;

  /// Список текстов дополнительных услуг.
  final RxList<String> additionalServicesTexts = <String>[].obs;

  /// Информация о клинере.
  final RxnString cleanerInfo = RxnString();

  /// URL аватара клинера.
  final RxnString cleanerAvatarUrl = RxnString();

  /// Рейтинг клинера.
  final RxDouble cleanerRating = 0.0.obs;

  /// Идентификатор клинера.
  final RxnInt cleanerId = RxnInt();

  /// Признак того, что клинер в избранном.
  final RxBool isFavoriteCleaner = false.obs;

  /// Текст статуса оплаты.
  final RxString _paymentText = 'Заказ не оплачен'.obs;

  /// URL для оплаты.
  final RxnString _paymentUrl = RxnString();
  final RxnString _paymentStatus = RxnString();

  /// Текст времени выполнения заказа.
  final RxString _executionTimeText = 'Время не указано'.obs;

  /// Текст статуса заказа.
  final RxString _statusText = 'Статус не указан'.obs;

  /// Создает контроллер деталей заказа.
  OrderDetailsController({
    required this.orderRepository,
    required this.favoriteCleanerRepository,
  });

  /// Возвращает заголовок для аппбара.
  String get appBarTitle {
    return 'A-${order.id}-${order.templateName}';
  }

  /// Возвращает текст статуса заказа.
  String get statusText {
    return _statusText.value;
  }

  /// Возвращает текст адреса.
  String get addressText {
    final String apartment = order.addressApartment == null ||
            order.addressApartment!.trim().isEmpty
        ? ''
        : ', кв. ${order.addressApartment}';
    return '${order.address.trim()}$apartment';
  }

  /// Возвращает текст даты и времени.
  String get dateTimeText {
    if (order.orderDate.isEmpty && order.orderTime.isEmpty) {
      return 'Дата не указана';
    }
    final String date = order.orderDate.isEmpty ? '' : order.orderDate;
    final String time =
        order.orderTime.isEmpty ? '' : (date.isEmpty ? order.orderTime : ', ${order.orderTime}');
    if (date.isEmpty && time.isNotEmpty) {
      return time.replaceFirst(', ', '');
    }
    return '$date$time';
  }

  /// Возвращает текст суммы заказа.
  String get totalPriceText {
    final int rounded = order.totalPrice.round();
    return '$rounded ₽';
  }

  /// Возвращает текст оплаты.
  String get paymentText {
    return _paymentText.value;
  }

  /// Возвращает текст времени выполнения заказа.
  String get executionTimeText {
    return _executionTimeText.value;
  }

  /// Возвращает цвет статуса оплаты.
  Color get paymentStatusColor {
    if (_paymentStatus.value == null || _paymentStatus.value!.isEmpty) {
      return const Color(0xFF4F4F4F); // AppColors.grayMedium
    }
    return PaymentStatusUtils.getStatusColor(_paymentStatus.value);
  }

  /// Проверяет, есть ли платеж.
  bool get hasPayment {
    return _paymentStatus.value != null && _paymentStatus.value!.isNotEmpty;
  }

  /// Проверяет, можно ли оплатить заказ (статус NEW и есть ссылка).
  bool get canPay {
    if (_paymentStatus.value == null || _paymentStatus.value!.isEmpty) {
      return false;
    }
    return _paymentStatus.value!.toUpperCase() == 'NEW' &&
        _paymentUrl.value != null &&
        _paymentUrl.value!.isNotEmpty;
  }

  /// Возвращает URL для оплаты.
  String? get paymentUrl {
    return _paymentUrl.value;
  }

  /// Возвращает дополнительный текст под статусом оплаты.
  String? get paymentAdditionalText {
    if (_paymentStatus.value == null || _paymentStatus.value!.isEmpty) {
      return null;
    }
    final String upperStatus = _paymentStatus.value!.toUpperCase();
    if (upperStatus == 'CANCELED' ||
        upperStatus == 'NEW' ||
        upperStatus == 'FORM_SHOWED' ||
        upperStatus == 'REVERSED') {
      return 'Оплатить можно будет за 4 часа до начала уборки';
    }
    if (upperStatus == 'DEADLINE_EXPIRED' || upperStatus == 'REJECTED') {
      return 'Нужно обратиться в сервис';
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    order = Get.arguments as OrderEntity;
    _statusText.value = _readStatusFromOrder(order);
    _initCleanerFromOrder();
    _loadOrderDetails();
  }

  void _initCleanerFromOrder() {
    if (order.cleanerName != null && order.cleanerName!.trim().isNotEmpty) {
      cleanerInfo.value = order.cleanerName!.trim();
    }
    if (order.cleanerId != null && order.cleanerId! > 0) {
      cleanerId.value = order.cleanerId;
      _loadFavoriteFlag(order.cleanerId!);
    }
  }

  Future<void> _loadOrderDetails() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final Map<String, dynamic> data =
          await orderRepository.getOrderDetails(order.id);
      final dynamic baseRaw =
          data['orderBaseServices'] ?? data['order_base_services'];
      final dynamic additionalRaw =
          data['orderAdditionalServices'] ?? data['order_additional_services'];
      baseServicesTexts
          .assignAll(_buildBaseServicesTexts(baseRaw));
      additionalServicesTexts
          .assignAll(
        _buildAdditionalServicesTexts(
          additionalRaw,
        ),
      );
      _updateStatusFromDetails(data);
      _updateCleanerFromDetails(data);
      _updatePaymentFromDetails(data);
      _updateExecutionTimeFromDetails(data);
    } catch (e) {
      errorMessage.value = 'Не удалось загрузить детали заказа. Попробуйте еще раз.';
    } finally {
      isLoading.value = false;
    }
  }

  List<String> _buildBaseServicesTexts(dynamic raw) {
    if (raw is! List<dynamic>) {
      return <String>[];
    }
    final List<String> result = <String>[];
    for (final dynamic item in raw) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final String name = (item['name'] as String? ?? 'Услуга').trim();
      int quantity = 0;
      if (item['pivot'] is Map<String, dynamic>) {
        final Map<String, dynamic> pivot =
            item['pivot'] as Map<String, dynamic>;
        final dynamic rawQuantity = pivot['quantity'];
        if (rawQuantity is int) {
          quantity = rawQuantity;
        } else if (rawQuantity is String) {
          quantity = int.tryParse(rawQuantity) ?? 0;
        }
      }
      if (quantity <= 0) {
        result.add(name);
        continue;
      }
      result.add('$name — $quantity');
    }
    return result;
  }

  List<String> _buildAdditionalServicesTexts(dynamic raw) {
    if (raw is! List<dynamic>) {
      return <String>[];
    }
    final List<String> result = <String>[];
    for (final dynamic item in raw) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final String name = (item['name'] as String? ?? 'Услуга').trim();
      final String type = (item['type'] as String? ?? '').trim();
      if (item['pivot'] is! Map<String, dynamic>) {
        continue;
      }
      final Map<String, dynamic> pivot =
          item['pivot'] as Map<String, dynamic>;
      if (type == 'toggle') {
        final dynamic rawToggle = pivot['toggle_value'];
        int toggleValue = 0;
        if (rawToggle is int) {
          toggleValue = rawToggle;
        } else if (rawToggle is String) {
          toggleValue = int.tryParse(rawToggle) ?? 0;
        }
        if (toggleValue == 1) {
          result.add(name);
        }
        continue;
      }
      int value = 0;
      final dynamic rawValue = pivot['value'];
      if (rawValue is int) {
        value = rawValue;
      } else if (rawValue is String) {
        value = int.tryParse(rawValue) ?? 0;
      }
      if (value <= 0) {
        continue;
      }
      result.add('$name — $value');
    }
    return result;
  }

  String _readStatusFromOrder(OrderEntity value) {
    final String? directName = value.status?.name;
    if (directName != null && directName.trim().isNotEmpty) {
      return directName.trim();
    }
    return _mapStatusIdToText(value.statusId);
  }

  void _updateStatusFromDetails(Map<String, dynamic> data) {
    String? statusName;

    // 1) Если статус пришел как объект
    if (data['status'] is Map<String, dynamic>) {
      final Map<String, dynamic> status =
          data['status'] as Map<String, dynamic>;
      statusName = (status['name'] as String? ??
              status['title'] as String? ??
              status['label'] as String?)
          ?.trim();
    }

    // 2) Если статус пришел как отдельное поле строкой
    if ((statusName == null || statusName.isEmpty) &&
        data['status_name'] is String) {
      statusName = (data['status_name'] as String).trim();
    }
    if ((statusName == null || statusName.isEmpty) &&
        data['status'] is String) {
      statusName = (data['status'] as String).trim();
    }

    // 3) Если нет строки, попробуем по идентификатору
    if ((statusName == null || statusName.isEmpty) &&
        data['status_id'] is int) {
      statusName = _mapStatusIdToText(data['status_id'] as int);
    }

    if (statusName != null && statusName.isNotEmpty) {
      _statusText.value = statusName;
    }
  }

  /// Маппинг числовых идентификаторов статуса в текст.
  String _mapStatusIdToText(int id) {
    switch (id) {
      case 1:
        return 'Ищем клинера';
      case 2:
        return 'Заказ принят';
      case 3:
        return 'Клинер в пути';
      case 4:
        return 'Начало работы';
      case 5:
        return 'Заказ выполнен';
      case 6:
        return 'Заказ завершен';
      default:
        return 'Статус не указан';
    }
  }

  void _updateCleanerFromDetails(Map<String, dynamic> data) {
    if (data['cleaner'] is Map<String, dynamic>) {
      final Map<String, dynamic> cleaner = data['cleaner'] as Map<String, dynamic>;
      final String firstName =
          (cleaner['name'] as String? ?? '').trim();
      final String lastName =
          (cleaner['lname'] as String? ??
                  cleaner['surname'] as String? ??
                  cleaner['last_name'] as String? ??
                  '')
              .trim();
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        final String fullName =
            (firstName.isNotEmpty && lastName.isNotEmpty)
                ? '$firstName $lastName'
                : (firstName.isNotEmpty ? firstName : lastName);
        cleanerInfo.value = fullName;
      }
      final String? avatar =
          (cleaner['profile_photo_url'] as String?) ??
              (cleaner['avatar_url'] as String?) ??
              (cleaner['avatar'] as String?) ??
              (cleaner['photo_url'] as String?);
      if (avatar != null && avatar.trim().isNotEmpty) {
        cleanerAvatarUrl.value = avatar.trim();
      }
      if (cleaner['id'] is int && cleaner['id'] > 0) {
        cleanerId.value = cleaner['id'] as int;
        _loadFavoriteFlag(cleaner['id'] as int);
      }
      final dynamic rawRating =
          cleaner['rating'] ?? cleaner['rating_avg'] ?? cleaner['rating_average'];
      double ratingValue = 0.0;
      if (rawRating is num) {
        ratingValue = rawRating.toDouble();
      } else if (rawRating is String) {
        ratingValue = double.tryParse(rawRating) ?? 0.0;
      }
      if (ratingValue < 0.0) {
        ratingValue = 0.0;
      }
      if (ratingValue > 5.0) {
        ratingValue = 5.0;
      }
      cleanerRating.value = ratingValue;
    }
  }

  Future<void> _loadFavoriteFlag(int id) async {
    try {
      final bool isFavorite = await favoriteCleanerRepository.isFavorite(id);
      isFavoriteCleaner.value = isFavorite;
    } catch (_) {
      isFavoriteCleaner.value = false;
    }
  }

  Future<void> toggleFavoriteCleaner() async {
    final int? id = cleanerId.value;
    if (id == null || id <= 0) {
      return;
    }
    final bool current = isFavoriteCleaner.value;
    isFavoriteCleaner.value = !current;
    try {
      if (!current) {
        await favoriteCleanerRepository.addFavorite(id);
      } else {
        await favoriteCleanerRepository.removeFavorite(id);
      }
    } catch (e) {
      isFavoriteCleaner.value = current;
    }
  }

  void _updatePaymentFromDetails(Map<String, dynamic> data) {
    if (data['payment'] is! Map<String, dynamic>) {
      _paymentText.value = 'Заказ не оплачен';
      _paymentStatus.value = null;
      _paymentUrl.value = null;
      return;
    }
    final Map<String, dynamic> payment =
        data['payment'] as Map<String, dynamic>;
    final String status = (payment['status'] as String? ?? '').trim();
    _paymentStatus.value = status;
    final String? paymentUrl = payment['payment_url'] as String?;
    _paymentUrl.value = paymentUrl;
    if (status.isEmpty) {
      _paymentText.value = 'Заказ не оплачен';
      return;
    }
    final String statusText = PaymentStatusUtils.getStatusText(status);
    _paymentText.value = statusText;
  }

  void _updateExecutionTimeFromDetails(Map<String, dynamic> data) {
    int? totalMinutes;
    final dynamic rawTotalTime = data['total_time'];
    if (rawTotalTime is int) {
      totalMinutes = rawTotalTime;
    } else if (rawTotalTime is String) {
      totalMinutes = int.tryParse(rawTotalTime);
    }
    if (totalMinutes == null || totalMinutes <= 0) {
      if (data['template'] is Map<String, dynamic>) {
        final Map<String, dynamic> template =
            data['template'] as Map<String, dynamic>;
        final dynamic rawBaseTime = template['base_time'];
        if (rawBaseTime is int) {
          totalMinutes = rawBaseTime;
        } else if (rawBaseTime is String) {
          totalMinutes = int.tryParse(rawBaseTime);
        }
      }
    }
    if (totalMinutes == null || totalMinutes <= 0) {
      _executionTimeText.value = 'Время не указано';
      return;
    }
    if (totalMinutes < 60) {
      _executionTimeText.value = '$totalMinutes мин';
      return;
    }
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    if (minutes == 0) {
      _executionTimeText.value = '$hours ч';
      return;
    }
    _executionTimeText.value = '$hours ч $minutes мин';
  }
}


