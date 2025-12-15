import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_assets.dart';
import '../../controllers/order_schedule_controller.dart';
import '../../widgets/common/primary_app_bar.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../../core/utils/haptic_utils.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// Экран выбора даты и времени уборки.
class OrderScheduleView extends GetView<OrderScheduleController> {
  /// Создает экран выбора даты и времени уборки.
  const OrderScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final String title = controller.templateController.templateTitle;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: title,
        canPop: true,
        hasMenu: true,
        onBackPressed: () => Get.back(),
      ),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _scheduleListHorizontalPadding,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: _scheduleListTopSpacing),
                      _ScheduleItem(
                        iconPath: AppAssets.iconCalendar,
                        valueListenable: controller.formattedDate,
                        placeholder: 'Дата',
                        onTap: () => _showDateSheet(context),
                      ),
                      const SizedBox(height: _scheduleItemsSpacing),
                      _ScheduleItem(
                        iconPath: AppAssets.iconClock,
                        valueListenable: controller.selectedTimeSlotText,
                        placeholder: 'Время',
                        onTap: () => _showTimeSheet(context),
                      ),
                      const SizedBox(height: _scheduleItemsSpacing),
                      Obx(() {
                        final List<OrderMultiVisitState> visits =
                            controller.additionalVisitStates;
                        if (visits.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final List<Widget> fields = <Widget>[];
                        for (int i = 0; i < visits.length; i++) {
                          final int displayIndex = i + 2;
                          if (fields.isNotEmpty) {
                            fields.add(const SizedBox(
                              height: _scheduleItemsSpacing,
                            ));
                          }
                          fields.add(
                            _ScheduleItem(
                              iconPath: AppAssets.iconCalendar,
                              valueListenable: visits[i].formattedDate,
                              placeholder: 'Дата визита $displayIndex',
                              onTap: () => _showDateSheet(
                                context,
                                additionalIndex: i,
                              ),
                            ),
                          );
                          fields.add(const SizedBox(
                            height: _scheduleItemsSpacing,
                          ));
                          fields.add(
                            _ScheduleItem(
                              iconPath: AppAssets.iconClock,
                              valueListenable: visits[i].formattedTime,
                              placeholder: 'Время визита $displayIndex',
                              onTap: () => _showTimeSheet(
                                context,
                                additionalIndex: i,
                              ),
                            ),
                          );
                        }
                        return Column(children: fields);
                      }),
                      const SizedBox(height: _scheduleItemsSpacing),
                      _ScheduleItem(
                        iconPath: AppAssets.iconPin,
                        valueListenable: controller.address,
                        placeholder: 'Адрес',
                        onTap: controller.executeSelectAddress,
                      ),
                      const SizedBox(height: _scheduleItemsSpacing),
                      _DoorCodeField(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
            _SaveButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

Future<void> _showTimeSheet(BuildContext context, {int? additionalIndex}) async {
  final OrderScheduleController controller =
      Get.find<OrderScheduleController>();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Выберите время',
                style: AppTypography.createTitle20(AppColors.grayDark),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.timeSlots.map((String slot) {
                    final String? currentSlot = additionalIndex == null
                        ? controller.selectedTimeSlot.value
                        : (additionalIndex >= 0 &&
                                additionalIndex <
                                    controller.additionalVisitStates.length
                            ? controller
                                .additionalVisitStates[additionalIndex]
                                .timeSlot
                                .value
                            : null);
                    final bool isSelected = currentSlot == slot;
                    return GestureDetector(
                      onTap: () {
                        HapticUtils.executeSelectionClick();
                        if (additionalIndex == null) {
                          controller.selectTimeSlot(slot);
                        } else {
                          controller.selectAdditionalTimeSlot(
                            additionalIndex,
                            slot,
                          );
                        }
                        Get.back();
                      },
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.mainPink
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.mainPink
                                : AppColors.grayLight.withValues(alpha: 0.6),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          slot,
                          style: AppTypography.createBody16(
                            isSelected ? AppColors.white : AppColors.grayDark,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showDateSheet(BuildContext context, {int? additionalIndex}) async {
  final OrderScheduleController controller =
      Get.find<OrderScheduleController>();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Выберите дату',
                style: AppTypography.createTitle20(AppColors.grayDark),
              ),
              const SizedBox(height: 16),
              Localizations.override(
                context: context,
                locale: const Locale('ru'),
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.single,
                  initialSelectedDate: additionalIndex == null
                      ? controller.selectedDate.value
                      : (additionalIndex >= 0 &&
                              additionalIndex <
                                  controller.additionalVisitStates.length
                          ? controller.additionalVisitStates[additionalIndex]
                              .date
                              .value
                          : null) ??
                          DateTime.now().add(const Duration(days: 1)),
                  minDate: DateTime.now().add(const Duration(days: 1)),
                  maxDate: DateTime.now().add(const Duration(days: 60)),
                  monthViewSettings: const DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1,
                  ),
                  headerStyle: const DateRangePickerHeaderStyle(
                    textStyle: TextStyle(
                      color: AppColors.grayDark,
                      fontSize: 18,
                    ),
                  ),
                  selectionColor: AppColors.mainPink,
                  todayHighlightColor: AppColors.mainPink,
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                        final DateTime? date = args.value as DateTime?;
                        if (date != null) {
                          HapticUtils.executeSelectionClick();
                          if (additionalIndex == null) {
                            controller.selectDate(date);
                          } else {
                            controller.selectAdditionalDate(
                              additionalIndex,
                              date,
                            );
                          }
                          Get.back();
                        }
                      },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

const double _scheduleListHorizontalPadding = 28;
const double _scheduleListTopSpacing = 32;
const double _scheduleItemsSpacing = 20;
const double _scheduleItemLeadingWidth = 36;
const double _scheduleItemContentSpacing = 8;
const double _scheduleItemIconSize = 28;
const double _scheduleItemDividerHeight = 1;
const double _scheduleItemVerticalPadding = 12;

class _DoorCodeField extends StatelessWidget {
  final OrderScheduleController controller;

  const _DoorCodeField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: _scheduleItemVerticalPadding,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: _scheduleItemLeadingWidth,
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.iconDoor,
                    width: _scheduleItemIconSize,
                    height: _scheduleItemIconSize,
                    colorFilter: const ColorFilter.mode(
                      AppColors.grayDark,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: _scheduleItemContentSpacing),
              Expanded(
                child: TextField(
                  controller: controller.doorCodeController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: '№ квартиры',
                    hintStyle: AppTypography.createBody16(AppColors.grayLight),
                    border: InputBorder.none,
                  ),
                  style: AppTypography.createBody16(AppColors.grayDark),
                  onChanged: controller.updateDoorCode,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: _scheduleItemDividerHeight,
          margin: const EdgeInsets.only(
            left: _scheduleItemLeadingWidth + _scheduleItemContentSpacing,
          ),
          color: AppColors.grayLight,
        ),
      ],
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String iconPath;
  final RxString valueListenable;
  final String placeholder;
  final Future<void> Function() onTap;

  const _ScheduleItem({
    required this.iconPath,
    required this.valueListenable,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        HapticUtils.executeSelectionClick();
        await onTap();
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: _scheduleItemVerticalPadding,
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: _scheduleItemLeadingWidth,
                  child: Center(
                    child: SvgPicture.asset(
                      iconPath,
                      width: _scheduleItemIconSize,
                      height: _scheduleItemIconSize,
                      colorFilter: const ColorFilter.mode(
                        AppColors.grayDark,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: _scheduleItemContentSpacing),
                Expanded(
                  child: Obx(() {
                    final String value = valueListenable.value.trim();
                    final bool isEmpty = value.isEmpty;
                    return Text(
                      isEmpty ? placeholder : value,
                      style: AppTypography.createBody16(
                        isEmpty ? AppColors.grayLight : AppColors.grayDark,
                      ),
                    );
                  }),
                ),
                const Icon(Icons.chevron_right, color: AppColors.grayDark),
              ],
            ),
          ),
          Container(
            height: _scheduleItemDividerHeight,
            margin: const EdgeInsets.only(
              left: _scheduleItemLeadingWidth + _scheduleItemContentSpacing,
            ),
            color: AppColors.grayLight,
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final OrderScheduleController controller;

  const _SaveButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.canContinue
                ? () async {
                    HapticUtils.executeSelectionClick();
                    await controller.executeSave();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.canContinue
                  ? AppColors.grayDark
                  : AppColors.grayMedium,
              foregroundColor: AppColors.white,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBackgroundColor: AppColors.grayMedium,
              disabledForegroundColor: AppColors.white,
            ),
            child: Text(
              'Продолжить',
              style: AppTypography.createBody16(AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}
