import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../controllers/payment_controller.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../widgets/common/primary_app_bar.dart';

/// Экран оплаты.
class PaymentView extends GetView<PaymentController> {
  /// Создает экран оплаты.
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(
        title: AppStrings.menuPayment,
        canPop: true,
        hasMenu: true,
      ),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (controller.hasError.value) {
            return _buildErrorState();
          }
          if (controller.cards.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildCardList();
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
              'Не удалось загрузить список карт.',
              textAlign: TextAlign.center,
          style: AppTypography.createBody16(AppColors.grayMedium),
        ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              HapticUtils.executeSelectionClick();
              controller.executeLoadCards();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainPink,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(AppStrings.continueAction),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppStrings.paymentEmptyTitle,
            textAlign: TextAlign.center,
            style: AppTypography.createBody16(AppColors.grayDark),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.paymentEmptyDescription,
            textAlign: TextAlign.center,
            style: AppTypography.createBody13(AppColors.grayMedium),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                HapticUtils.executeSelectionClick();
                final dynamic result =
                    await Get.toNamed(AppRoutes.paymentAddCard);
                if (result == true) {
                  await controller.executeLoadCards();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(AppStrings.paymentAddCardAction),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            itemBuilder: (BuildContext context, int index) {
              final card = controller.cards[index];
              return _PaymentCardTile(
                cardNumber: card.maskedPan,
                cardHolder: card.holderName ?? '',
                brand: card.brand ?? '',
                isDefault: card.isDefault,
                onDefaultChanged: (bool value) {
                  if (!value) {
                    return;
                  }
                  controller.executeSetDefaultCard(card);
                },
                onDeletePressed: () => controller.executeDeleteCard(card),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 12);
            },
            itemCount: controller.cards.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                HapticUtils.executeSelectionClick();
                final dynamic result =
                    await Get.toNamed(AppRoutes.paymentAddCard);
                if (result == true) {
                  await controller.executeLoadCards();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(AppStrings.paymentAddCardAction),
            ),
          ),
        ),
      ],
    );
  }
}

/// Карточка сохранённой банковской карты.
class _PaymentCardTile extends StatelessWidget {
  /// Маскированный номер карты.
  final String cardNumber;

  /// Владелец карты.
  final String cardHolder;

  /// Платёжная система.
  final String brand;

  /// Признак карты по умолчанию.
  final bool isDefault;

  /// Обработчик изменения статуса по умолчанию.
  final ValueChanged<bool> onDefaultChanged;

  /// Обработчик удаления карты.
  final VoidCallback onDeletePressed;

  /// Создаёт карточку сохранённой банковской карты.
  const _PaymentCardTile({
    required this.cardNumber,
    required this.cardHolder,
    required this.brand,
    required this.isDefault,
    required this.onDefaultChanged,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppStrings.paymentCardNumberLabel,
                      style: AppTypography.createBody13(AppColors.grayMedium),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cardNumber,
                      style: AppTypography.createBody16(AppColors.grayDark),
                    ),
                  ],
                ),
              ),
              if (brand.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    brand,
                    style: AppTypography.createBody13(AppColors.grayMedium),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.paymentCardHolderLabel,
            style: AppTypography.createBody13(AppColors.grayMedium),
          ),
          const SizedBox(height: 4),
          Text(
            cardHolder.isEmpty ? '-' : cardHolder.toUpperCase(),
            style: AppTypography.createBody16(AppColors.grayDark),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    CupertinoSwitch(
                      value: isDefault,
                      activeColor: AppColors.mainPink,
                      trackColor: AppColors.grayLight,
            onChanged: (bool isEnabled) {
              HapticUtils.executeSelectionClick();
              onDefaultChanged(isEnabled);
            },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppStrings.paymentCardDefaultLabel,
                        style:
                            AppTypography.createBody13(AppColors.grayMedium),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticUtils.executeSelectionClick();
                  onDeletePressed();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mainPink,
                ),
                child: const Text('Удалить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

