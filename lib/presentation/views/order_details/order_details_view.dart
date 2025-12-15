import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../widgets/common/primary_app_bar.dart';
import '../../controllers/order_details_controller.dart';

/// Экран деталей заказа.
class OrderDetailsView extends GetView<OrderDetailsController> {
  /// Создает экран деталей заказа.
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: controller.appBarTitle,
        canPop: true,
        hasMenu: true,
        onBackPressed: Get.back,
      ),
      endDrawer: const MainMenuDrawer(),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.baseServicesTexts.isEmpty &&
              controller.additionalServicesTexts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final String? error = controller.errorMessage.value;
          if (error != null && error.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: AppTypography.createBody16(AppColors.grayDark),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller
                          .onInit, // повторный вызов перезагрузит данные
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _OrderMainInfo(controller: controller),
                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.grayLight),
                const SizedBox(height: 20),
                _ServicesSection(
                  title: 'Базовые услуги',
                  items: controller.baseServicesTexts,
                ),
                const SizedBox(height: 20),
                if (controller.additionalServicesTexts.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _ServicesSection(
                        title: 'Дополнительные услуги',
                        items: controller.additionalServicesTexts,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                if (controller.cleanerInfo.value != null &&
                    controller.cleanerInfo.value!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Divider(height: 1, color: AppColors.grayLight),
                      const SizedBox(height: 20),
                      _CleanerInfo(controller: controller),
                    ],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _OrderMainInfo extends StatelessWidget {
  final OrderDetailsController controller;

  const _OrderMainInfo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Информация о заказе',
            style: AppTypography.createTitle20(AppColors.grayDark),
          ),
          const SizedBox(height: 12),
          _MainInfoRow(
            icon: Icons.info_outline,
            label: 'Статус',
            value: controller.statusText,
          ),
          const SizedBox(height: 12),
          _MainInfoRow(
            icon: Icons.location_on,
            label: 'Адрес',
            value: controller.addressText,
          ),
          const SizedBox(height: 12),
          _MainInfoRow(
            icon: Icons.access_time,
            label: 'Время выполнения',
            value: controller.executionTimeText,
          ),
          const SizedBox(height: 12),
          _MainInfoRow(
            icon: Icons.event,
            label: 'Дата и время',
            value: controller.dateTimeText,
          ),
          const SizedBox(height: 12),
          _MainInfoRow(
            icon: Icons.payments,
            label: 'Сумма',
            value: controller.totalPriceText,
          ),
          const SizedBox(height: 12),
          _PaymentInfoSection(controller: controller),
        ],
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _ServicesSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTypography.createTitle20(AppColors.grayDark),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
              child: _ServiceItemRow(text: items[i]),
            ),
        ],
      ),
    );
  }
}

class _ServiceItemRow extends StatelessWidget {
  final String text;

  const _ServiceItemRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split('—');
    final String name = parts.first.trim();
    final String? value =
        parts.length > 1 ? parts.sublist(1).join('—').trim() : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.check_circle_outline,
          size: 18,
          color: AppColors.grayMedium,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: value == null || value.isEmpty
              ? Text(
                  name,
                  style: AppTypography.createBody16(AppColors.grayDark),
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        name,
                        style: AppTypography.createBody16(AppColors.grayDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: AppTypography.createBody13(AppColors.grayMedium),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _CleanerInfo extends StatelessWidget {
  final OrderDetailsController controller;

  const _CleanerInfo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Клинер',
            style: AppTypography.createTitle20(AppColors.grayDark),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _CleanerAvatar(controller: controller),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      controller.cleanerInfo.value ?? '',
                      style: AppTypography.createBody16(AppColors.grayDark),
                    ),
                    const SizedBox(height: 4),
                    _CleanerRating(controller: controller),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                final bool isFavorite = controller.isFavoriteCleaner.value;
                return IconButton(
                  onPressed: controller.toggleFavoriteCleaner,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.mainPink : AppColors.grayLight,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _CleanerAvatar extends StatelessWidget {
  final OrderDetailsController controller;

  const _CleanerAvatar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = controller.cleanerAvatarUrl.value;
    final String name = controller.cleanerInfo.value ?? '';
    final String initials = _buildInitials(name);
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.grayLight,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.grayLight,
      child: Text(
        initials,
        style: AppTypography.createBody16(AppColors.grayDark),
      ),
    );
  }

  String _buildInitials(String value) {
    if (value.trim().isEmpty) {
      return '';
    }
    final List<String> parts = value.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
    }
    final String first = parts[0];
    final String second = parts[1];
    final String firstLetter =
        first.isNotEmpty ? first[0].toUpperCase() : '';
    final String secondLetter =
        second.isNotEmpty ? second[0].toUpperCase() : '';
    return '$firstLetter$secondLetter';
  }
}

class _CleanerRating extends StatelessWidget {
  final OrderDetailsController controller;

  const _CleanerRating({required this.controller});

  @override
  Widget build(BuildContext context) {
    final double rating = controller.cleanerRating.value;
    if (rating <= 0.0) {
      return Text(
        'Рейтинг отсутствует',
        style: AppTypography.createBody13(AppColors.grayMedium),
      );
    }
    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.5;
    final int totalStars = 5;
    final List<Widget> stars = <Widget>[];
    for (int i = 0; i < totalStars; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, size: 16, color: Colors.amber));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, size: 16, color: Colors.amber));
      } else {
        stars.add(const Icon(Icons.star_border, size: 16, color: Colors.amber));
      }
    }
    stars.add(
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          rating.toStringAsFixed(1),
          style: AppTypography.createBody13(AppColors.grayDark),
        ),
      ),
    );
    return Row(children: stars);
  }
}

class _MainInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MainInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
                style: AppTypography.createBody13(AppColors.grayMedium),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentInfoSection extends StatelessWidget {
  final OrderDetailsController controller;

  const _PaymentInfoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool hasPayment = controller.hasPayment;
    final bool canPay = controller.canPay;
    final String? paymentUrl = controller.paymentUrl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.account_balance_wallet,
          size: 20,
          color: AppColors.grayMedium,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Оплата',
                style: AppTypography.createBody13(AppColors.grayMedium),
              ),
              const SizedBox(height: 4),
              if (!hasPayment) ...[
                Text(
                  'За 4 часа до начала придет ссылка на оплату заказа',
                  style: AppTypography.createBody16(AppColors.grayMedium),
                ),
              ] else ...[
                Text(
                  controller.paymentText,
                  style: AppTypography.createBody16(controller.paymentStatusColor),
                ),
                if (controller.paymentAdditionalText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    controller.paymentAdditionalText!,
                    style: AppTypography.createBody13(AppColors.grayMedium),
                  ),
                ],
                if (canPay && paymentUrl != null && paymentUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticUtils.executeSelectionClick();
                        try {
                          final Uri uri = Uri.parse(paymentUrl);
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grayDark,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
      ],
    );
  }
}

class _PaymentInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PaymentInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
                style: AppTypography.createBody13(AppColors.grayMedium),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.createBody16(color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

