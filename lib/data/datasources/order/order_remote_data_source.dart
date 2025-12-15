import 'package:dio/dio.dart';

import '../../../core/constants/app_urls.dart';
import '../../models/order/order_entity.dart';

/// Загружает и создает заказы через REST API.
class OrderRemoteDataSource {
  /// Клиент HTTP.
  final Dio dio;

  /// Создает источник данных заказов.
  const OrderRemoteDataSource({required this.dio});

  /// Создает заказ.
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      AppUrls.createOrder,
      data: payload,
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  /// Удаляет заказ.
  Future<Map<String, dynamic>> deleteOrder(int orderId) async {
    final Response<dynamic> response = await dio.delete<dynamic>(
      AppUrls.createDeleteOrderPath(orderId),
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  /// Получает список заказов пользователя.
  Future<List<OrderEntity>> getOrders() async {
    try {
      print('=== Начало запроса заказов ===');
      print('URL: ${AppUrls.getOrders}');
      print('Base URL: ${dio.options.baseUrl}');
      print('Полный URL: ${dio.options.baseUrl}${AppUrls.getOrders}');
      final Response<dynamic> response = await dio.get<dynamic>(
        AppUrls.getOrders,
      );
      print('Статус ответа: ${response.statusCode}');
      print('Заголовки запроса: ${response.requestOptions.headers}');
      print('Заголовки ответа: ${response.headers}');
      if (response.data != null) {
        print('Тип данных ответа: ${response.data.runtimeType}');
        final String dataStr = response.data.toString();
        print('Ответ API заказов (первые 500 символов): ${dataStr.length > 500 ? dataStr.substring(0, 500) : dataStr}');
      } else {
        print('Ответ API пустой (null)');
      }
      final List<OrderEntity> orders = <OrderEntity>[];
      if (response.data == null) {
        print('Ответ API пустой, возвращаем пустой список');
        return orders;
      }
      if (response.data is List<dynamic>) {
        final List<dynamic> ordersData = response.data as List<dynamic>;
        print('Получен массив заказов, количество: ${ordersData.length}');
        for (final dynamic item in ordersData) {
          if (item is Map<String, dynamic>) {
            try {
              final OrderEntity order = OrderEntity.fromJson(item);
              if (order.id > 0) {
                orders.add(order);
                print('Заказ добавлен: id=${order.id}, type=${order.orderType}');
              } else {
                print('Заказ пропущен: id=0, данные: $item');
              }
            } catch (e, stackTrace) {
              print('Ошибка парсинга заказа: $e');
              print('Stack trace: $stackTrace');
              print('Данные: $item');
            }
          }
        }
        print('Итого распарсено заказов: ${orders.length}');
        return orders;
      }
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        dynamic ordersData = data['data'];
        if (ordersData == null && data['orders'] != null) {
          ordersData = data['orders'];
        }
        if (ordersData is List<dynamic>) {
          print('Получен массив заказов из объекта, количество: ${ordersData.length}');
          for (final dynamic item in ordersData) {
            if (item is Map<String, dynamic>) {
              try {
                final OrderEntity order = OrderEntity.fromJson(item);
                if (order.id > 0) {
                  orders.add(order);
                  print('Заказ добавлен: id=${order.id}, type=${order.orderType}');
                } else {
                  print('Заказ пропущен: id=0, данные: $item');
                }
              } catch (e, stackTrace) {
                print('Ошибка парсинга заказа: $e');
                print('Stack trace: $stackTrace');
                print('Данные: $item');
              }
            }
          }
          print('Итого распарсено заказов: ${orders.length}');
        } else {
          print('ordersData не является списком: $ordersData (тип: ${ordersData.runtimeType})');
        }
      } else {
        print('Неожиданный формат ответа: ${response.data.runtimeType}');
      }
      return orders;
    } catch (e, stackTrace) {
      print('Ошибка при получении заказов: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Получает детальную информацию о заказе.
  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      print('Запрос деталей заказа: ${AppUrls.getOrders}/$orderId');
      final Response<dynamic> response = await dio.get<dynamic>(
        '${AppUrls.getOrders}/$orderId',
      );
      print('Статус ответа: ${response.statusCode}');
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        if (data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
        return data;
      }
      return <String, dynamic>{};
    } catch (e, stackTrace) {
      print('Ошибка при получении деталей заказа: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

