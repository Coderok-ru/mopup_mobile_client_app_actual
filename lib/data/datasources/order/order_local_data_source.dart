import 'package:get_storage/get_storage.dart';

import '../../models/order/order_entity.dart';

/// Локальный источник данных для заказов.
class OrderLocalDataSource {
  /// Хранилище ключ-значение.
  final GetStorage storage;

  static const String _ordersKey = 'orders_cache';

  /// Создает локальный источник данных.
  const OrderLocalDataSource({required this.storage});

  /// Загружает закешированные заказы.
  Future<List<OrderEntity>> loadOrders() async {
    final List<dynamic>? raw = storage.read<List<dynamic>>(_ordersKey);
    if (raw == null) {
      return <OrderEntity>[];
    }
    final List<OrderEntity> orders = <OrderEntity>[];
    for (final dynamic item in raw) {
      if (item is Map<String, dynamic>) {
        try {
          orders.add(OrderEntity.fromJson(item));
        } catch (_) {}
      }
    }
    return orders;
  }

  /// Сохраняет список заказов в локальное хранилище.
  Future<void> saveOrders(List<OrderEntity> orders) async {
    final List<Map<String, dynamic>> data =
        orders.map((OrderEntity e) => e.toJson()).toList();
    await storage.write(_ordersKey, data);
  }

  /// Очищает кеш заказов.
  Future<void> clearOrders() async {
    await storage.remove(_ordersKey);
  }
}


