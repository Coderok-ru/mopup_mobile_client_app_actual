import 'package:get/get.dart';

import '../../data/models/order/order_entity.dart';
import '../../data/repositories/order/order_repository.dart';
import '../../data/services/notifications/notification_service.dart';
import '../../routes/app_routes.dart';

/// Доступные фильтры списка заказов.
enum OrdersFilter {
  /// Все заказы.
  all,

  /// Текущие и активные заказы.
  active,

  /// Завершенные заказы.
  completed,
}

/// Контроллер экрана заказов.
class OrdersController extends GetxController {
  /// Репозиторий заказов.
  final OrderRepository orderRepository;

  /// Сервис локальных уведомлений.
  final NotificationService notificationService;

  /// Список заказов.
  final RxList<OrderEntity> orders = <OrderEntity>[].obs;

  /// Состояние загрузки.
  final RxBool isLoading = false.obs;

  /// Сообщение об ошибке.
  final RxnString errorMessage = RxnString();

  /// Выбранный фильтр заказов.
  final Rx<OrdersFilter> selectedFilter = OrdersFilter.all.obs;

  /// Создает контроллер заказов.
  OrdersController({
    required this.orderRepository,
    required this.notificationService,
  });

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  /// Загружает список заказов.
  Future<void> loadOrders({bool forceRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      print('Начало загрузки заказов...');
      final List<OrderEntity> loadedOrders =
          await orderRepository.getOrders(forceRefresh: forceRefresh);
      print('Загружено заказов: ${loadedOrders.length}');
      orders.value = loadedOrders;
      print('Заказы установлены в контроллер: ${orders.length}');
    } catch (e, stackTrace) {
      errorMessage.value = 'Не удалось загрузить заказы. Попробуйте еще раз.';
      print('Ошибка загрузки заказов: $e');
      print('Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      print('Загрузка завершена. isLoading: ${isLoading.value}, orders: ${orders.length}');
    }
  }

  /// Открывает экран с детальной информацией о заказе.
  void openOrderDetails(OrderEntity order) {
    Get.toNamed(
      AppRoutes.orderDetails,
      arguments: order,
    );
  }

  /// Обновляет список заказов.
  Future<void> refreshOrders() async {
    await loadOrders(forceRefresh: true);
  }

  /// Отменяет заказ.
  Future<void> cancelOrder(int orderId) async {
    print('Отмена заказа: $orderId');
    try {
      await orderRepository.deleteOrder(orderId);
      orders.removeWhere((OrderEntity order) => order.id == orderId);
      await notificationService.executeShowOrderDeletedNotification();
    } catch (e, stackTrace) {
      print('Ошибка при отмене заказа: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Возвращает количество активных заказов.
  int get activeOrdersCount => orders.where(_isActive).length;

  /// Возвращает количество завершенных заказов.
  int get completedOrdersCount => orders.where(_isCompleted).length;

  /// Возвращает отфильтрованный список заказов.
  List<OrderEntity> get filteredOrders {
    final OrdersFilter filter = selectedFilter.value;
    switch (filter) {
      case OrdersFilter.active:
        return orders.where(_isActive).toList();
      case OrdersFilter.completed:
        return orders.where(_isCompleted).toList();
      case OrdersFilter.all:
        return orders.toList();
    }
  }

  /// Устанавливает выбранный фильтр.
  void selectFilter(OrdersFilter filter) {
    if (selectedFilter.value == filter) {
      return;
    }
    selectedFilter.value = filter;
  }

  bool _isActive(OrderEntity order) {
    return order.statusId == 1 || order.statusId == 2 || order.statusId == 3;
  }

  bool _isCompleted(OrderEntity order) {
    return order.statusId >= 4;
  }
}

