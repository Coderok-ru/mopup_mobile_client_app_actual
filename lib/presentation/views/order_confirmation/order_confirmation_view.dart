import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/primary_app_bar.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../controllers/order_confirmation_controller.dart';
import '../../models/order_confirmation_view_model.dart';

/// Экран подтверждения заказа.
class OrderConfirmationView extends GetView<OrderConfirmationController> {
  /// Создает экран подтверждения заказа.
  const OrderConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderConfirmationViewModel model = controller.viewModel;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: 'Подтверждение',
        canPop: true,
        hasMenu: true,
        onBackPressed: Get.back,
      ),
      endDrawer: const MainMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_contentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Подтверждение заказа',
                      style: AppTypography.createTitle24(AppColors.grayDark),
                    ),
                    const SizedBox(height: _sectionSpacing),
                    _OrderInfoCard(model: model),
                  ],
                ),
              ),
            ),
            _ConfirmButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  final OrderConfirmationViewModel model;

  const _OrderInfoCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final bool isMulty = model.payload['order_type'] == 'multy';
    final String dateTimeText = isMulty
        ? 'Дата первого визита: ${model.formattedDate} в ${model.formattedTime}'
        : '${model.formattedDate} в ${model.formattedTime}';
    final String addressText = model.doorCode != 'Не указан'
        ? '${model.address}, кв. ${model.doorCode}'
        : model.address;
    final String totalPriceText = '${model.totalPrice.round()} ₽';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoRow(
            icon: Icons.calendar_today,
            label: 'Дата и время',
            value: dateTimeText,
          ),
          const SizedBox(height: _itemSpacing),
          const Divider(height: 1, color: AppColors.grayLight),
          const SizedBox(height: _itemSpacing),
          _InfoRow(
            icon: Icons.location_on,
            label: 'Адрес',
            value: addressText,
          ),
          const SizedBox(height: _itemSpacing),
          const Divider(height: 1, color: AppColors.grayLight),
          const SizedBox(height: _itemSpacing),
          _InfoRow(
            icon: Icons.payments,
            label: 'К оплате',
            value: totalPriceText,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isTotal;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = isTotal
        ? AppTypography.createTitle20(AppColors.grayDark)
        : AppTypography.createBody16(AppColors.grayMedium);
    final TextStyle valueStyle = isTotal
        ? AppTypography.createTitle20(AppColors.grayDark)
        : AppTypography.createBody16(AppColors.grayDark);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          size: 20,
          color: AppColors.grayMedium,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: labelStyle,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final OrderConfirmationController controller;

  const _ConfirmButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_contentPadding),
      child: Obx(() {
        final bool isLoading = controller.isLoading.value;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : controller.confirmOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grayDark,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.grayLight,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Text(
                    'Подтвердить',
                    style: AppTypography.createBody16(AppColors.white),
                  ),
          ),
        );
      }),
    );
  }
}

const double _contentPadding = 24;
const double _cardPadding = 20;
const double _sectionSpacing = 20;
const double _itemSpacing = 16;
