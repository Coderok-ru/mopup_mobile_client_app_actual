import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/order/order_additional_service_entity.dart';
import '../../widgets/common/primary_app_bar.dart';
import '../../controllers/order_template_controller.dart';
import '../../widgets/order/additional_number_stepper.dart';
import '../../widgets/order/base_service_slider.dart';
import '../../widgets/common/main_menu_drawer.dart';

/// Экран выбора услуг шаблона.
class OrderTemplateView extends GetView<OrderTemplateController> {
  /// Создает экран шаблона заказа.
  const OrderTemplateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: controller.templateTitle,
        canPop: true,
        hasMenu: true,
        onBackPressed: () => Get.back(),
      ),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _TemplateLoading();
          }
          final String? error = controller.errorMessage.value;
          if (error != null && error.isNotEmpty) {
            return _TemplateMessage(message: error);
          }
          if (controller.baseServiceStates.isEmpty) {
            return const _TemplateMessage(
              message: 'Для шаблона не найдены базовые услуги.',
            );
          }
          final List<Widget> children = <Widget>[];
          for (final OrderBaseServiceState state
              in controller.baseServiceStates) {
            children.add(
              _BaseServiceTile(
                state: state,
                onValueChanged: (double value) =>
                    controller.changeBaseServiceValue(state.service.id, value),
              ),
            );
            children.add(const SizedBox(height: 16));
          }
          if (children.isNotEmpty) {
            children.removeLast();
          }
          children.add(const SizedBox(height: 24));
          children.add(_AdditionalServicesSection(controller: controller));
          children.add(const SizedBox(height: 24));
          children.add(_SummarySection(controller: controller));
          children.add(const SizedBox(height: 24));
          children.add(_ContinueButton(controller: controller));
          children.add(const SizedBox(height: 32));
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: children,
          );
        }),
      ),
    );
  }
}

class _BaseServiceTile extends StatelessWidget {
  final OrderBaseServiceState state;
  final ValueChanged<double> onValueChanged;

  const _BaseServiceTile({required this.state, required this.onValueChanged});

  @override
  Widget build(BuildContext context) {
    final int min = state.minSliderValue;
    final int max = state.maxSliderValue;
    final List<int> steps = state.effectiveSteps;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Obx(() {
        final int currentValue =
            state.normalizeValue(state.value.value).round().clamp(min, max);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    state.service.title,
                    style: AppTypography.createBody16(AppColors.grayDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BaseServiceSlider(
              min: min,
              max: max,
              value: currentValue,
              steps: steps.isEmpty ? null : steps,
              onChanged: (int changed) => onValueChanged(changed.toDouble()),
            ),
          ],
        );
      }),
    );
  }
}

class _TemplateLoading extends StatelessWidget {
  const _TemplateLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _TemplateMessage extends StatelessWidget {
  final String message;

  const _TemplateMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.createBody16(AppColors.grayDark),
        ),
      ),
    );
  }
}

class _AdditionalServicesSection extends StatelessWidget {
  final OrderTemplateController controller;

  const _AdditionalServicesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool expanded = controller.isAdditionalExpanded.value;
      final List<OrderAdditionalServiceState> states =
          controller.additionalServiceStates;
      final bool hasServices = states.isNotEmpty;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () {
                HapticUtils.executeSelectionClick();
                controller.toggleAdditional();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Дополнительные услуги',
                        style: AppTypography.createTitle20(AppColors.grayDark),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 28,
                        color: AppColors.grayDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: hasServices
                    ? Column(
                        children: states
                            .map(
                              (OrderAdditionalServiceState state) =>
                                  _AdditionalServiceItem(
                                    controller: controller,
                                    state: state,
                                  ),
                            )
                            .toList(),
                      )
                    : Text(
                        'Нет доступных дополнительных услуг.',
                        style: AppTypography.createBody16(AppColors.grayMedium),
                      ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      );
    });
  }
}

class _AdditionalServiceItem extends StatelessWidget {
  final OrderTemplateController controller;
  final OrderAdditionalServiceState state;

  const _AdditionalServiceItem({required this.controller, required this.state});

  @override
  Widget build(BuildContext context) {
    final OrderAdditionalServiceEntity service = state.service;
    final bool isToggle = service.type == 'toggle';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              service.title,
              style: AppTypography.createBody16(AppColors.grayDark),
            ),
          ),
          if (isToggle) ...<Widget>[
            Obx(
              () => Transform.scale(
                scale: 0.9,
                child: CupertinoSwitch(
                  value: state.isEnabled.value,
                  activeColor: AppColors.mainPink,
                  thumbColor: AppColors.white,
                  onChanged: (bool value) {
                    HapticUtils.executeSelectionClick();
                    controller.toggleAdditionalService(service.id, value);
                  },
                ),
              ),
            ),
          ] else
            Obx(() {
              final int value = state.quantity.value;
              return AdditionalNumberStepper(
                value: value,
                onIncrement: () =>
                    controller.increaseAdditionalQuantity(service.id),
                onDecrement: () =>
                    controller.decreaseAdditionalQuantity(service.id),
                canIncrement: value < OrderAdditionalServiceState.maxQuantity,
                canDecrement: value > OrderAdditionalServiceState.minQuantity,
              );
            }),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final OrderTemplateController controller;

  const _SummarySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final double base = controller.baseTotal.value;
      final double additional = controller.additionalTotal.value;
      final double total = controller.totalPrice.value;
      final OrderMultiSelection multi = controller.currentMultiSelection;
      final int multiplier = multi.multiplier > 0 ? multi.multiplier : 1;
      final String perVisitDuration = _formatDuration(controller.totalTime.value);
      final String duration = multiplier > 1
          ? '$multiplier х $perVisitDuration'
          : perVisitDuration;
      final double discount = controller.draft.discountAmount;
      final double discountFactor =
          multi.hasDiscount ? 1 - (multi.discountPercent / 100) : 1;
      final double baseWithDiscount = base * discountFactor;
      final double additionalWithDiscount = additional * discountFactor;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: <Widget>[
            _SummaryRow(
              label: 'К оплате',
              value: _formatCurrency(total),
              isTotal: true,
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.grayLight),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Уборка',
              value: _formatCurrency(baseWithDiscount),
              isTotal: false,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Дополнительные услуги',
              value: _formatCurrency(additionalWithDiscount),
              isTotal: false,
            ),
            if (multi.hasDiscount && discount > 0) ...<Widget>[
              const SizedBox(height: 12),
              _SummaryRow(
                label: 'Скидка',
                value:
                    '${multi.discountPercent}% (-${_formatCurrency(discount)})',
                isTotal: false,
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.grayLight),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Время',
              value: duration,
              isTotal: false,
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isTotal,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle style = isTotal
        ? AppTypography.createTitle20(AppColors.grayDark)
        : AppTypography.createBody16(AppColors.grayMedium);
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final OrderTemplateController controller;

  const _ContinueButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticUtils.executeSelectionClick();
          controller.proceed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.grayDark,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Продолжить',
          style: AppTypography.createBody16(AppColors.white),
        ),
      ),
    );
  }
}

String _formatCurrency(double value) {
  final int rounded = value.round();
  return '$rounded ₽';
}

String _formatDuration(int minutes) {
  if (minutes <= 0) {
    return '0 мин.';
  }
  final int hours = minutes ~/ 60;
  final int rest = minutes % 60;
  if (hours == 0) {
    return '$minutes мин.';
  }
  if (rest == 0) {
    return '$hours ч.';
  }
  return '$hours ч. $rest мин.';
}
