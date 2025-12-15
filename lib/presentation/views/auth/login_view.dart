import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../../core/utils/haptic_utils.dart';

/// Экран авторизации.
class LoginView extends GetView<AuthController> {
  /// Создает экран авторизации.
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: SvgPicture.asset(AppAssets.logo, width: 282),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: <Widget>[
                              Text(
                                AppStrings.loginSubtitlePrefix,
                                style: AppTypography.createBody13(
                                  AppColors.grayDark,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticUtils.executeSelectionClick();
                                  controller.openRegistration();
                                },
                                child: Text(
                                  AppStrings.loginSubtitleAction,
                                  style: AppTypography.createBody13(
                                    AppColors.mainPink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Obx(
                            () => AuthTextField(
                              controller: controller.loginPhoneController,
                              hint: AppStrings.phoneHint,
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                controller.loginPhoneFormatter,
                              ],
                              showCheck: controller.hasLoginPhone.value,
                            ),
                          ),
                          const SizedBox(height: _loginFieldSpacing),
                          AuthTextField(
                            controller: controller.loginPasswordController,
                            hint: AppStrings.passwordHint,
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    Obx(() {
                      final bool isDisabled = controller.isBusy.value;
                      return SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: isDisabled
                              ? null
                              : () {
                                  HapticUtils.executeSelectionClick();
                                  controller.executeLogin();
                                },
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
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.background,
                                  ),
                                )
                              : Text(
                                  AppStrings.loginAction,
                                  style: AppTypography.createBody16(
                                    AppColors.background,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const double _loginFieldSpacing = 28;
