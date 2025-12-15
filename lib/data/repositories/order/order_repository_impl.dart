import 'dart:async';

import '../../datasources/order/order_local_data_source.dart';
import '../../datasources/order/order_remote_data_source.dart';
import '../../models/order/order_entity.dart';
import 'order_repository.dart';

/// Репозиторий заказов.
class OrderRepositoryImpl implements OrderRepository {
  /// Удаленный источник данных.
  final OrderRemoteDataSource remoteDataSource;

  /// Локальный источник данных.
  final OrderLocalDataSource localDataSource;

  /// Создает репозиторий заказов.
  const OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    final Map<String, dynamic> result =
        await remoteDataSource.createOrder(payload);
    // После создания заказа обновляем кеш заказов.
    unawaited(_refreshAndCache());
    return result;
  }

  @override
  Future<List<OrderEntity>> getOrders({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final List<OrderEntity> cached = await localDataSource.loadOrders();
      if (cached.isNotEmpty) {
        // Параллельно обновляем данные из сети.
        unawaited(_refreshAndCache());
        return cached;
      }
    }
    return _refreshAndCache();
  }

  /// Обновляет данные заказов из сети и сохраняет их в кеш.
  Future<List<OrderEntity>> _refreshAndCache() async {
    final List<OrderEntity> remote = await remoteDataSource.getOrders();
    await localDataSource.saveOrders(remote);
    return remote;
  }

  @override
  Future<Map<String, dynamic>> getOrderDetails(int orderId) {
    return remoteDataSource.getOrderDetails(orderId);
  }

  @override
  Future<Map<String, dynamic>> deleteOrder(int orderId) async {
    final Map<String, dynamic> result = await remoteDataSource.deleteOrder(orderId);
    // После удаления принудительно обновляем кеш заказов.
    await _refreshAndCache();
    return result;
  }
}

