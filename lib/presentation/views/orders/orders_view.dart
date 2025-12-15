import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/payment_status_utils.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../widgets/common/primary_app_bar.dart';
import '../../../data/models/order/order_entity.dart';
import '../../controllers/orders_controller.dart';

/// Экран заказов.
class OrdersView extends GetView<OrdersController> {
  /// Создает экран заказов.
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(
        title: AppStrings.menuOrders,
        canPop: true,
        hasMenu: true,
      ),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: Obx(() {
          print(
            'OrdersView rebuild: isLoading=${controller.isLoading.value}, orders=${controller.orders.length}, filtered=${controller.filteredOrders.length}, error=${controller.errorMessage.value}',
          );
          if (controller.isLoading.value && controller.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final String? error = controller.errorMessage.value;
          if (error != null && error.isNotEmpty && controller.orders.isEmpty) {
            return _ErrorState(
              message: error,
              onRetry: controller.loadOrders,
            );
          }
          final List<OrderEntity> filteredOrders = controller.filteredOrders;
          return EasyRefresh(
            header: const ClassicHeader(
              dragText: 'Потяните, чтобы обновить',
              armedText: 'Отпустите, чтобы обновить',
              readyText: 'Обновляем...',
              processingText: 'Обновляем...',
              processedText: 'Обновлено',
              noMoreText: 'Больше нет данных',
              failedText: 'Не удалось обновить',
              messageText: 'Последнее обновление: %T',
            ),
            onRefresh: controller.refreshOrders,
            child: filteredOrders.isEmpty
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    children: <Widget>[
                      _EmptyFilteredState(
                        onRefresh: controller.loadOrders,
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: filteredOrders.length,
                    itemBuilder: (BuildContext context, int index) {
                      final OrderEntity order = filteredOrders[index];
                      final bool isLast = index == filteredOrders.length - 1;
                      return Column(
                        children: <Widget>[
                          _OrderCard(
                            order: order,
                            onTap: () {
                              HapticUtils.executeSelectionClick();
                              controller.openOrderDetails(order);
                            },
                            onCancel: () {
                              HapticUtils.executeSelectionClick();
                              _showCancelBottomSheet(
                                context: context,
                                orderId: order.id,
                              );
                            },
                          ),
                          if (!isLast)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: AppColors.grayLight),
                            ),
                        ],
                      );
                    },
                  ),
          );
        }),
      ),
    );
  }
}

void _showCancelBottomSheet({
  required BuildContext context,
  required int orderId,
}) {
  Get.bottomSheet(
    _CancelOrderBottomSheet(
      onConfirm: () {
        HapticUtils.executeSelectionClick();
        Get.back();
        final OrdersController controller = Get.find<OrdersController>();
        controller.cancelOrder(orderId);
      },
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

class _CancelOrderBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const _CancelOrderBottomSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 34),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'Подтвердите отмену заказа.',
                textAlign: TextAlign.center,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
              const SizedBox(height: 40),
              Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grayDark,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Не отменять'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: onConfirm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.grayDark,
                          side: const BorderSide(color: AppColors.grayDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Отменить'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Экран больше не использует отдельный заголовок — карточки выводятся сразу.

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.createBody16(AppColors.grayMedium),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              HapticUtils.executeSelectionClick();
              onRetry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grayDark,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilteredState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyFilteredState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.grayLight.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: <Widget>[
              Text(
                'Нет заказов по выбранному фильтру',
                textAlign: TextAlign.center,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
              const SizedBox(height: 12),
              Text(
                'Попробуйте переключить фильтр или обновить список',
                textAlign: TextAlign.center,
                style: AppTypography.createBody13(AppColors.grayMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            HapticUtils.executeSelectionClick();
            onRefresh();
          },
          child: const Text('Обновить'),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final String title = _buildTitle(order);
    final String address = _buildAddress(order);
    final String schedule = _buildSchedule(order);
    final String paymentStatus = _buildPaymentStatus(order);
    final Color paymentStatusColor = _getPaymentStatusColor(order);
    final String priceText = _formatPrice(order.totalPrice);
    final bool hasCleaner = order.cleanerId != null && order.cleanerId! > 0;
    final bool canCancel = order.statusId == 1;
    final IconData cleanerIcon =
        hasCleaner ? Icons.check_circle : Icons.search;
    final Color cleanerColor =
        hasCleaner ? AppColors.accentGreen : AppColors.accentBlue;
    final String cleanerLabel = hasCleaner
        ? (order.cleanerName ?? 'Клинер назначен')
        : 'Ищем клинера';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTypography.createTitle20(AppColors.grayDark),
                    ),
                    const SizedBox(height: 6),
                      Text(
                        address,
                        style: AppTypography.createBody13(AppColors.grayMedium),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule,
                        style: AppTypography.createBody13(AppColors.grayMedium),
                      ),
                      if (order.payment == null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'За 4 часа до начала придет ссылка на оплату заказа',
                          style: AppTypography.createBody13(AppColors.grayMedium),
                        ),
                      ] else if (paymentStatus.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          paymentStatus,
                          style: AppTypography.createBody13(paymentStatusColor),
                        ),
                        if (_getPaymentAdditionalText(order) != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _getPaymentAdditionalText(order)!,
                            style: AppTypography.createBody13(AppColors.grayMedium),
                          ),
                        ],
                        if (order.payment!.status.toUpperCase() == 'NEW' &&
                            order.payment!.paymentUrl != null &&
                            order.payment!.paymentUrl!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticUtils.executeSelectionClick();
                                _openPaymentUrl(order.payment!.paymentUrl!);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.grayDark,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Оплатить заказ',
                                style: AppTypography.createBody16(AppColors.white),
                              ),
                            ),
                          ),
                        ],
                      ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    priceText,
                    style: AppTypography.createTitle20(AppColors.grayDark),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      HapticUtils.executeSelectionClick();
                      onTap();
                    },
                    child: const Text(
                      'Подробности',
                      style: TextStyle(color: AppColors.accentBlue),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                cleanerIcon,
                color: cleanerColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  cleanerLabel,
                  style: AppTypography.createBody16(cleanerColor),
                ),
              ),
              if (canCancel)
                TextButton(
                  onPressed: () {
                    HapticUtils.executeSelectionClick();
                    onCancel();
                  },
                  child: const Text(
                    'Отменить',
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildTitle(OrderEntity order) {
    final String code = 'A-${order.id}';
    final String template = order.templateName;
    return '$code-$template';
  }

  String _buildAddress(OrderEntity order) {
    final String apartment =
        order.addressApartment == null || order.addressApartment!.trim().isEmpty
            ? ''
            : ', кв. ${order.addressApartment}';
    String cleaned = order.address;
    cleaned = cleaned.replaceAll(RegExp(r'Россия,?\s*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(', ,', ',').trim();
    if (cleaned.startsWith(',')) {
      cleaned = cleaned.substring(1).trim();
    }
    return '${cleaned.trim()}$apartment';
  }

  String _buildSchedule(OrderEntity order) {
    if (order.orderDate.isEmpty && order.orderTime.isEmpty) {
      return 'Дата не указана';
    }
    final String formattedDate = _formatDate(order.orderDate);
    final String time = order.orderTime.isEmpty ? '' : ', ${order.orderTime}';
    return '$formattedDate$time';
  }

  String _formatDate(String date) {
    if (date.isEmpty) {
      return 'Дата не указана';
    }
    final List<String> parts = date.split('.');
    if (parts.length != 3) {
      return date;
    }
    final int? day = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    if (day == null || month == null) {
      return date;
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
    if (month < 1 || month > 12) {
      return date;
    }
    return '$day ${months[month - 1]}';
  }

  String _formatPrice(double value) {
    final int rounded = value.round();
    final String digits = rounded.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final int remaining = digits.length - i - 1;
      if (remaining % 3 == 0 && remaining != 0) {
        buffer.write(' ');
      }
    }
    return '${buffer.toString()} ₽';
  }

  String _buildPaymentStatus(OrderEntity order) {
    if (order.payment == null) {
      return '';
    }
    return PaymentStatusUtils.getStatusText(order.payment!.status);
  }

  Color _getPaymentStatusColor(OrderEntity order) {
    if (order.payment == null) {
      return AppColors.grayMedium;
    }
    return PaymentStatusUtils.getStatusColor(order.payment!.status);
  }

  String? _getPaymentAdditionalText(OrderEntity order) {
    if (order.payment == null) {
      return null;
    }
    final String upperStatus = order.payment!.status.toUpperCase();
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

  Future<void> _openPaymentUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Ошибка при открытии ссылки на оплату: $e');
    }
  }
}
