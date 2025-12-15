import 'dart:convert';

import 'package:get/get.dart';

import '../../data/models/address/address_selection_model.dart';
import '../../data/models/auth/user_entity.dart';
import '../../data/models/order/order_additional_service_entity.dart';
import '../../data/models/order/order_base_service_entity.dart';
import '../../data/repositories/address/address_repository.dart';
import '../../data/repositories/order/order_repository.dart';
import '../../data/services/notifications/notification_service.dart';
import '../../routes/app_routes.dart';
import '../models/order_confirmation_view_model.dart';
import 'auth_controller.dart';
import 'order_template_controller.dart';
import 'orders_controller.dart';

/// Контроллер экрана подтверждения заказа.
class OrderConfirmationController extends GetxController {
  /// Контроллер шаблона заказа.
  final OrderTemplateController templateController;

  /// Контроллер авторизации.
  final AuthController authController;

  /// Репозиторий адреса.
  final AddressRepository addressRepository;

  /// Репозиторий заказов.
  final OrderRepository orderRepository;

  /// Сервис локальных уведомлений.
  final NotificationService notificationService;

  /// Модель представления.
  late final OrderConfirmationViewModel viewModel;

  /// Состояние загрузки.
  final RxBool isLoading = false.obs;

  /// Создает контроллер.
  OrderConfirmationController({
    required this.templateController,
    required this.authController,
    required this.addressRepository,
    required this.orderRepository,
    required this.notificationService,
  });

  @override
  void onInit() {
    super.onInit();
    viewModel = _buildViewModel();
  }

  OrderConfirmationViewModel _buildViewModel() {
    final UserEntity? user = authController.currentUser.value;
    final String customerName = user == null ? 'Неизвестный клиент' : user.getFullName();
    final String customerPhone = user == null || user.phone.trim().isEmpty ? 'Не указан' : user.phone.trim();
    final OrderTemplateDraft draft = templateController.draft;
    final int? templateId = draft.templateId == null || draft.templateId == 0
        ? templateController.templateId
        : draft.templateId;
    final int? cityId = draft.cityId ?? authController.selectedCityId.value ?? user?.cityId;
    final AddressSelectionModel? selection = addressRepository.loadSelection();
    final String formattedDate = _formatDate(draft.serviceDate);
    final String formattedTime = _formatTime(draft.serviceTimeSlot);
    final String address = _resolveAddress(selection, draft.address);
    final String doorCode = _resolveDoorCode(draft.doorCode);
    final String? rawAddress = _extractRawAddress(selection, draft.address);
    final String? rawDoorCode = _extractRawDoorCode(draft.doorCode);
    final String? backendDate = _formatBackendDate(draft.serviceDate);
    final String? backendTime = _formatBackendTime(draft.serviceTimeSlot);
    final Map<String, dynamic> payload = <String, dynamic>{
      'city_id': cityId,
      'template_id': templateId,
      'order_type': draft.isRegular ? 'multy' : 'single',
      'public_status': draft.isPublic,
      'dates': backendDate ?? '',
      'times': backendTime ?? '',
      'name': user?.getFullName() ?? '',
      'phone': user?.phone ?? '',
      'address_address': rawAddress ?? '',
      'address_kv': rawDoorCode ?? '',
      'latitude': selection?.latitude,
      'longitude': selection?.longitude,
      'base_price': templateController.baseTotal.value,
      'discount': templateController.draft.discountAmount,
      'total_price': templateController.totalPrice.value,
      'total_time': templateController.totalTime.value,
      'order_base_services': _buildBaseServicesPayload(),
      'order_additional_services': _buildAdditionalServicesPayload(),
      'order_dates': draft.isRegular ? _buildOrderDatesPayload() : <Map<String, dynamic>>[],
    };
    final String jsonPayload = const JsonEncoder.withIndent('  ').convert(payload);
    return OrderConfirmationViewModel(
      customerName: customerName,
      customerPhone: customerPhone,
      userId: user?.id,
      templateId: templateId,
      cityId: cityId,
      formattedDate: formattedDate,
      formattedTime: formattedTime,
      address: address,
      doorCode: doorCode,
      latitude: selection?.latitude,
      longitude: selection?.longitude,
      basePrice: templateController.baseTotal.value,
      additionalPrice: templateController.additionalTotal.value,
      totalPrice: templateController.totalPrice.value,
      totalTimeMinutes: templateController.totalTime.value,
      payload: payload,
      jsonPayload: jsonPayload,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Дата не выбрана';
    }
    const List<String> months = <String>[
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String? time) {
    if (time == null || time.trim().isEmpty) {
      return 'Время не выбрано';
    }
    return time.trim();
  }

  String _resolveAddress(AddressSelectionModel? selection, String? draftAddress) {
    if (draftAddress != null && draftAddress.trim().isNotEmpty) {
      return draftAddress.trim();
    }
    if (selection != null && selection.formattedAddress.trim().isNotEmpty) {
      return selection.formattedAddress.trim();
    }
    return 'Адрес не указан';
  }

  String _resolveDoorCode(String? code) {
    if (code == null) {
      return 'Не указан';
    }
    final String trimmed = code.trim();
    if (trimmed.isEmpty) {
      return 'Не указан';
    }
    return trimmed;
  }

  String? _extractRawAddress(AddressSelectionModel? selection, String? draftAddress) {
    if (draftAddress != null && draftAddress.trim().isNotEmpty) {
      return draftAddress.trim();
    }
    if (selection != null && selection.formattedAddress.trim().isNotEmpty) {
      return selection.formattedAddress.trim();
    }
    return null;
  }

  String? _extractRawDoorCode(String? code) {
    if (code == null) {
      return null;
    }
    final String trimmed = code.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _formatBackendDate(DateTime? date) {
    if (date == null) {
      return null;
    }
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day.$month.$year';
  }

  String? _formatBackendTime(String? time) {
    if (time == null) {
      return null;
    }
    final String trimmed = time.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  List<Map<String, dynamic>> _buildBaseServicesPayload() {
    return templateController.baseServiceStates.map((OrderBaseServiceState state) {
      final OrderBaseServiceEntity service = state.service;
      final int quantity = state.value.value.round();
      return <String, dynamic>{
        'id': service.id,
        'quantity': quantity,
        'applied_discount': 0,
        'price': service.price,
        'position': service.position,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildAdditionalServicesPayload() {
    return templateController.additionalServiceStates.map((OrderAdditionalServiceState state) {
      final OrderAdditionalServiceEntity service = state.service;
      final bool isToggle = state.isToggle;
      final int quantity = isToggle ? 0 : state.quantity.value;
      final int toggleValue = isToggle ? (state.isEnabled.value ? 1 : 0) : 0;
      final double price = isToggle
          ? (toggleValue == 1 ? service.price : 0)
          : (quantity > 0 ? service.price : 0);
      final Map<String, dynamic> item = <String, dynamic>{
        'id': service.id,
        'value': quantity,
        'toggle_value': toggleValue,
        'price': price,
        'position': service.position,
      };
      if (isToggle) {
        item['type'] = 'toggle';
      }
      return item;
    }).toList();
  }

  List<Map<String, dynamic>> _buildOrderDatesPayload() {
    final List<OrderDraftScheduleVisit> visits =
        templateController.draft.additionalVisits;
    if (visits.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    return visits.map((OrderDraftScheduleVisit visit) {
      final String? date = _formatBackendDate(visit.date);
      final String? time = _formatBackendTime(visit.time);
      return <String, dynamic>{
        'date': date ?? '',
        'time': time ?? '',
      };
    }).toList();
  }

  /// Подтверждает и отправляет заказ.
  Future<void> confirmOrder() async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    try {
      await orderRepository.createOrder(viewModel.payload);
      await notificationService.executeShowOrderCreatedNotification();
      await _executeReloadOrders();
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      // Ошибку можно обработать позже через отдельный UI.
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _executeReloadOrders() async {
    if (!Get.isRegistered<OrdersController>()) {
      return;
    }
    final OrdersController ordersController = Get.find<OrdersController>();
    await ordersController.loadOrders(forceRefresh: true);
  }
}

