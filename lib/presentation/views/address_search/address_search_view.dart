import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../controllers/address_search_controller.dart';
import '../../widgets/common/primary_app_bar.dart';
import '../../../data/services/location/yandex_search_service.dart';

/// Экран поиска адреса.
class AddressSearchView extends GetView<AddressSearchController> {
  /// Создает экран поиска адреса.
  const AddressSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: 'Поиск адреса',
        canPop: true,
        onBackPressed: () => Get.back(),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Ваш город',
                    style: AppTypography.createBody13(AppColors.grayLight),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: TextField(
                          controller: controller.cityController,
                          readOnly: true,
                          style: AppTypography.createBody16(AppColors.grayDark),
                          decoration: InputDecoration(
                            hintText: 'Город не указан',
                            hintStyle: AppTypography.createBody16(AppColors.grayLight),
                            isDense: true,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: AppColors.grayMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Улица и дом',
                    style: AppTypography.createBody13(AppColors.grayLight),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: TextField(
                          controller: controller.searchController,
                          autofocus: true,
                          style: AppTypography.createBody16(AppColors.grayDark),
                          decoration: InputDecoration(
                            hintText: 'Введите адрес',
                            hintStyle: AppTypography.createBody16(AppColors.grayLight),
                            isDense: true,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: AppColors.grayMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (controller.searchResults.isEmpty) {
                  if (controller.searchController.text.trim().isEmpty) {
                    return Center(
                      child: Text(
                        'Введите адрес для поиска',
                        style: AppTypography.createBody16(AppColors.grayLight),
                      ),
                    );
                  }
                  return Center(
                    child: Text(
                      'Адреса не найдены',
                      style: AppTypography.createBody16(AppColors.grayLight),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.searchResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    final AddressSearchResult result =
                        controller.searchResults[index];
                    final String formattedAddress =
                        controller.formatAddress(
                      result.formattedAddress,
                      controller.cityName.value,
                    );
                    return InkWell(
                      onTap: () {
                        HapticUtils.executeSelectionClick();
                        controller.selectAddress(result);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.location_on,
                              color: AppColors.grayDark,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                formattedAddress,
                                style: AppTypography.createBody16(
                                  AppColors.grayDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

