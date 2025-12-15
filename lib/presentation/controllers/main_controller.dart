import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/models/order/order_template_summary_entity.dart';
import '../../data/repositories/order/order_template_repository.dart';
import '../../data/services/notifications/notification_service.dart';
import '../models/order_template_detail_args.dart';
import 'auth_controller.dart';
import '../../routes/app_routes.dart';

/// Контроллер главного экрана с шаблонами услуг.
class MainController extends GetxController {
  /// Репозиторий шаблонов заказов.
  final OrderTemplateRepository orderTemplateRepository;

  /// Контроллер авторизации.
  final AuthController authController;

  /// Сервис уведомлений.
  final NotificationService notificationService;

  /// Загруженные шаблоны.
  final RxList<OrderTemplateSummaryEntity> templates =
      <OrderTemplateSummaryEntity>[].obs;

  /// Состояние загрузки.
  final RxBool isLoading = false.obs;

  /// Сообщение об ошибке.
  final RxnString errorMessage = RxnString();

  Worker? _cityWatcher;
  int? _lastLoadedCityId;

  /// Создает контроллер главного экрана.
  MainController({
    required this.orderTemplateRepository,
    required this.authController,
    required this.notificationService,
  });

  @override
  void onInit() {
    super.onInit();
    _sendPlayerIdData();
    _cityWatcher = ever<int?>(
      authController.selectedCityId,
      _handleCityChanged,
    );
    final int? initialCityId =
        authController.selectedCityId.value ??
        authController.currentUser.value?.cityId;
    if (initialCityId != null) {
      _handleCityChanged(initialCityId);
      return;
    }
    authController.loadCities().then((_) {
      final int? resolvedCityId = authController.selectedCityId.value;
      if (resolvedCityId != null) {
        _handleCityChanged(resolvedCityId);
      }
    });
  }

  @override
  void onClose() {
    _cityWatcher?.dispose();
    super.onClose();
  }

  /// Перезагружает шаблоны вручную.
  Future<void> reloadTemplates() async {
    final int? cityId = authController.selectedCityId.value;
    if (cityId == null) {
      return;
    }
    await _loadTemplates(cityId);
  }

  /// Открывает экран шаблона.
  void openTemplate(OrderTemplateSummaryEntity templateSummary) {
    Get.toNamed(
      AppRoutes.orderTemplate,
      arguments: OrderTemplateDetailArgs(template: templateSummary),
    );
  }

  void _handleCityChanged(int? cityId) {
    if (cityId == null) {
      templates.clear();
      errorMessage.value = 'Выберите город для отображения шаблонов.';
      return;
    }
    if (_lastLoadedCityId == cityId && templates.isNotEmpty) {
      return;
    }
    errorMessage.value = null;
    unawaited(_loadTemplates(cityId));
  }

  Future<void> _loadTemplates(int cityId) async {
    isLoading.value = true;
    try {
      final List<OrderTemplateSummaryEntity> loaded =
          await orderTemplateRepository.loadTemplates(cityId);
      templates.assignAll(loaded);
      _lastLoadedCityId = cityId;
      if (loaded.isEmpty) {
        errorMessage.value = 'Для выбранного города нет шаблонов услуг.';
      } else {
        errorMessage.value = null;
      }
    } on DioException catch (error) {
      errorMessage.value = _resolveDioMessage(error);
    } catch (_) {
      errorMessage.value = 'Не удалось загрузить шаблоны услуг.';
    } finally {
      isLoading.value = false;
    }
  }

  String _resolveDioMessage(DioException error) {
    final dynamic data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final dynamic message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!.trim();
    }
    return 'Ошибка сети при загрузке шаблонов.';
  }

  /// Отправляет данные устройства на сервер для push-уведомлений.
  Future<void> _sendPlayerIdData() async {
    if (!authController.isAuthenticated.value) {
      print('⚠️ Пользователь не авторизован, пропускаем отправку player-id');
      return;
    }
    try {
      final String? fcmToken = await notificationService.executeGetFCMToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        print('⚠️ FCM токен не получен, пропускаем отправку player-id');
        return;
      }
      final String platform = GetPlatform.isIOS ? 'ios' : 'android';
      print('📤 Отправка player-id: device_token=${fcmToken.substring(0, 20)}..., platform=$platform');
      await authController.authRepository.sendPlayerId(
        deviceToken: fcmToken,
        platform: platform,
      );
      print('✅ Данные player-id успешно отправлены: platform=$platform');
    } on DioException catch (error) {
      print('❌ Ошибка Dio при отправке player-id:');
      print('   Status: ${error.response?.statusCode}');
      print('   Method: ${error.requestOptions.method}');
      print('   URL: ${error.requestOptions.uri}');
      print('   Data: ${error.requestOptions.data}');
      print('   Response: ${error.response?.data}');
    } catch (error) {
      print('❌ Неизвестная ошибка при отправке player-id: $error');
    }
  }
}
