import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../controllers/add_payment_card_controller.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/common/primary_app_bar.dart';

/// Экран добавления новой банковской карты.
class AddPaymentCardView extends GetView<AddPaymentCardController> {
  /// Создает экран добавления карты.
  const AddPaymentCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(
        title: AppStrings.paymentAddCardAction,
        canPop: true,
        hasMenu: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                AppStrings.paymentCardNumberLabel,
                style: AppTypography.createBody13(AppColors.grayMedium),
              ),
              const SizedBox(height: 4),
              AuthTextField(
                controller: controller.cardNumberController,
                hint: '4300 **** **** 1234',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  controller.cardNumberFormatter,
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.paymentCardHolderLabel,
                style: AppTypography.createBody13(AppColors.grayMedium),
              ),
              const SizedBox(height: 4),
              AuthTextField(
                controller: controller.cardHolderController,
                hint: 'IVAN IVANOV',
                 textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 24),
              Obx(
                () {
                  final String? message = controller.errorMessage.value;
                  if (message == null || message.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      message,
                      style: AppTypography.createBody13(AppColors.errorRed),
                    ),
                  );
                },
              ),
              Obx(
                () {
                  return Row(
                    children: <Widget>[
                      CupertinoSwitch(
                        value: controller.isDefault.value,
                        activeColor: AppColors.mainPink,
                        trackColor: AppColors.grayLight,
                        onChanged: (bool value) {
                          controller.isDefault.value = value;
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.paymentCardDefaultLabel,
                          style: AppTypography.createBody13(
                            AppColors.grayMedium,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              Obx(
                () {
                  return SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.isBusy.value
                          ? null
                          : controller.executeSaveCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isBusy.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Text(AppStrings.paymentAddCardAction),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


