import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/auth/user_entity.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/avatar_picker.dart';
import '../../widgets/auth/city_dropdown.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../widgets/common/primary_app_bar.dart';

/// Экран личного кабинета.
class AccountView extends GetView<AuthController> {
  /// Создает экран личного кабинета.
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadCities();
    if (controller.currentUser.value == null) {
      controller.refreshProfile();
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(
        title: AppStrings.menuPersonalAccount,
        canPop: true,
        hasMenu: true,
      ),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: Obx(() {
          final UserEntity? user = controller.currentUser.value;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.mainPink),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _accountHorizontalPadding,
              _accountTopPadding,
              _accountHorizontalPadding,
              _accountBottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Obx(
                  () => Center(
                    child: AvatarPicker(
                      imageBytes: controller.profileAvatarBytes.value,
                      imageUrl: controller.currentUser.value?.avatarUrl,
                      initials: controller.currentUser.value?.getInitials(),
                      onTap: () => _showAvatarSourceSheet(context),
                      onRemove: controller.profileAvatarBytes.value == null
                          ? null
                          : controller.clearProfileAvatar,
                      size: 124,
                    ),
                  ),
                ),
                const SizedBox(height: _accountAvatarSpacing),
                AuthTextField(
                  controller: controller.profileNameController,
                  hint: AppStrings.nameHint,
                ),
                const SizedBox(height: _accountFieldSpacing),
                AuthTextField(
                  controller: controller.profileSurnameController,
                  hint: AppStrings.surnameHint,
                ),
                const SizedBox(height: _accountFieldSpacing),
                AuthTextField(
                  controller: controller.profilePhoneController,
                  hint: AppStrings.phoneHint,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    controller.profilePhoneFormatter,
                  ],
                ),
                const SizedBox(height: _accountFieldSpacing),
                AuthTextField(
                  controller: controller.profileEmailController,
                  hint: AppStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: _accountFieldSpacing),
                Obx(
                  () => CityDropdown(
                    cities: controller.cities.toList(),
                    selectedId: controller.selectedCityId.value,
                    onChanged: controller.selectCity,
                  ),
                ),
                const SizedBox(height: _accountSectionSpacing),
                Obx(() {
                  final bool isDisabled = controller.isBusy.value;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isDisabled
                          ? null
                          : controller.executeProfileUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grayDark,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isDisabled
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : Text(
                              AppStrings.saveAction,
                              style: AppTypography.createBody16(
                                AppColors.background,
                              ),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: _accountFieldSpacing),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: controller.executeLogout,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.grayDark,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppStrings.logoutAction,
                      style: AppTypography.createBody16(AppColors.grayDark),
                    ),
                  ),
                ),
                const SizedBox(height: _accountFooterSpacing),
                Center(
                  child: TextButton(
                    onPressed: () => _confirmDelete(context),
                    child: Text(
                      AppStrings.deleteAccountAction,
                      style: AppTypography.createBody16(AppColors.mainPink),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showAvatarSourceSheet(BuildContext context) {
    final bool hasLocalAvatar = controller.profileAvatarBytes.value != null;
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(
                AppStrings.avatarChooseFromGallery,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
              onTap: () async {
                Get.back();
                await controller.pickProfileAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(
                AppStrings.avatarTakePhoto,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
              onTap: () async {
                Get.back();
                await controller.pickProfileAvatar(ImageSource.camera);
              },
            ),
            if (hasLocalAvatar)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(
                  AppStrings.avatarRemove,
                  style: AppTypography.createBody16(AppColors.grayDark),
                ),
                onTap: () {
                  Get.back();
                  controller.clearProfileAvatar();
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(
                AppStrings.cancelAction,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
              onTap: Get.back,
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(
          AppStrings.deleteAccountAction,
          style: AppTypography.createTitle20(AppColors.grayDark),
        ),
        content: Text(
          AppStrings.deleteAccountConfirmation,
          style: AppTypography.createBody16(AppColors.grayDark),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: Get.back,
            child: Text(
              AppStrings.cancelAction,
              style: AppTypography.createBody16(AppColors.grayMedium),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.executeDeleteAccount();
            },
            child: Text(
              AppStrings.deleteAccountAction,
              style: AppTypography.createBody16(AppColors.mainPink),
            ),
          ),
        ],
      ),
    );
  }
}

const double _accountHorizontalPadding = 48;
const double _accountTopPadding = 32;
const double _accountBottomPadding = 72;
const double _accountAvatarSpacing = 32;
const double _accountFieldSpacing = 28;
const double _accountSectionSpacing = 28;
const double _accountFooterSpacing = 20;
