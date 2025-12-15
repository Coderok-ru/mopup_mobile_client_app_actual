import '../../models/order/order_entity.dart';

/// Контракт работы с заказами.
abstract class OrderRepository {
  /// Создает заказ.
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload);

  /// Получает список заказов пользователя.
  ///
  /// [forceRefresh] при значении `true` игнорирует локальный кеш и
  /// выполняет запрос к серверу.
  Future<List<OrderEntity>> getOrders({bool forceRefresh = false});

  /// Получает детальную информацию о заказе.
  Future<Map<String, dynamic>> getOrderDetails(int orderId);

  /// Удаляет заказ.
  Future<Map<String, dynamic>> deleteOrder(int orderId);
}

