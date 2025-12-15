import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/city_dropdown.dart';
import '../../widgets/auth/avatar_picker.dart';
import '../../../routes/app_routes.dart';

/// Экран регистрации.
class RegistrationView extends GetView<AuthController> {
  /// Создает экран регистрации.
  const RegistrationView({super.key});

  void _showAvatarSourceSheet(BuildContext context) {
    final bool hasAvatar = controller.registrationAvatarBytes.value != null;
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
                HapticUtils.executeSelectionClick();
                Get.back();
                await controller.pickRegistrationAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(
                AppStrings.avatarTakePhoto,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
              onTap: () async {
                HapticUtils.executeSelectionClick();
                Get.back();
                await controller.pickRegistrationAvatar(ImageSource.camera);
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(
                  AppStrings.avatarRemove,
                  style: AppTypography.createBody16(AppColors.grayDark),
                ),
                onTap: () {
                  HapticUtils.executeSelectionClick();
                  Get.back();
                  controller.clearRegistrationAvatar();
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(
                AppStrings.cancelAction,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
              onTap: () {
                HapticUtils.executeSelectionClick();
                Get.back();
              },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.grayDark,
        leading: IconButton(
          onPressed: () {
            HapticUtils.executeSelectionClick();
            controller.openLogin();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          AppStrings.registrationTitle,
          style: AppTypography.createTitle20(AppColors.white),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return ColoredBox(
              color: AppColors.white,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(48, 36, 48, 61),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Obx(
                          () => Center(
                            child: AvatarPicker(
                              imageBytes:
                                  controller.registrationAvatarBytes.value,
                              onTap: () => _showAvatarSourceSheet(context),
                              onRemove:
                                  controller.registrationAvatarBytes.value ==
                                      null
                                  ? null
                                  : controller.clearRegistrationAvatar,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Obx(
                          () => AuthTextField(
                            controller: controller.registrationPhoneController,
                            hint: AppStrings.phoneHint,
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              controller.registrationPhoneFormatter,
                            ],
                            showCheck: controller.hasRegistrationPhone.value,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          controller: controller.registrationPasswordController,
                          hint: AppStrings.passwordHint,
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          controller:
                              controller.registrationPasswordConfirmController,
                          hint: AppStrings.confirmPasswordHint,
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => AuthTextField(
                            controller: controller.registrationNameController,
                            hint: AppStrings.nameHint,
                            showCheck: controller.hasRegistrationName.value,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => AuthTextField(
                            controller:
                                controller.registrationSurnameController,
                            hint: AppStrings.surnameHint,
                            showCheck: controller.hasRegistrationSurname.value,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          controller: controller.registrationEmailController,
                          hint: AppStrings.emailHint,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => CityDropdown(
                            cities: controller.cities.toList(),
                            selectedId: controller.selectedCityId.value,
                            onChanged: controller.selectCity,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Obx(
                          () => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 44,
                                height: 27,
                                child: CupertinoSwitch(
                                  value: controller.hasAcceptedAgreement.value,
                                  onChanged: (_) =>
                                      controller.toggleAgreement(),
                                  activeTrackColor: AppColors.grayDark,
                                  inactiveTrackColor: AppColors.grayLight
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTypography.createBody13(
                                      AppColors.grayMedium,
                                    ),
                                    children: <InlineSpan>[
                                      const TextSpan(
                                        text: '${AppStrings.agreementPrefix} ',
                                      ),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {
                                            HapticUtils.executeSelectionClick();
                                            Get.toNamed(
                                              AppRoutes.offer,
                                            );
                                          },
                                          child: Text(
                                            AppStrings.agreementLink,
                                            style: AppTypography.createBody13(
                                              AppColors.mainPink,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' ${AppStrings.agreementSuffix}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Obx(() {
                          final bool isDisabled = controller.isBusy.value;
                          return Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 180,
                                child: OutlinedButton(
                                  onPressed: isDisabled
                                    ? null
                                    : () {
                                        HapticUtils.executeSelectionClick();
                                        controller.executeRegistration();
                                      },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.grayMedium,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: isDisabled
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        AppStrings.registrationAction,
                                        style: AppTypography.createBody16(
                                          AppColors.grayMedium,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
