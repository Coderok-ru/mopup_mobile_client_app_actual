import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../widgets/common/primary_app_bar.dart';

/// Экран с информацией о приложении.
class AboutView extends StatelessWidget {
  /// Создает экран «О приложении».
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(
        title: AppStrings.menuAbout,
        canPop: true,
        hasMenu: true,
      ),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.aboutAppTitle,
                style: AppTypography.createBody16(AppColors.grayDark),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.aboutAppDescription,
                style: AppTypography.createBody16(AppColors.grayMedium),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.aboutAppFeatures,
                style: AppTypography.createBody16(AppColors.grayMedium),
              ),
              const SizedBox(height: 24),
              const _VersionInfo(),
              const SizedBox(height: 32),
              _buildContactsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            AppStrings.aboutSupportPhone,
            textAlign: TextAlign.center,
            style: AppTypography.createBody16(AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.aboutSupportEmail,
            textAlign: TextAlign.center,
            style: AppTypography.createBody16(AppColors.white),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.aboutCompanyName,
            textAlign: TextAlign.center,
            style: AppTypography.createBody16(AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.aboutPaymentMethods,
            textAlign: TextAlign.center,
            style: AppTypography.createBody13(AppColors.white),
          ),
        ],
      ),
    );
  }
}

/// Виджет с информацией о версии приложения.
class _VersionInfo extends StatelessWidget {
  /// Создает виджет версии приложения.
  const _VersionInfo();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final PackageInfo info = snapshot.data!;
        final String version = info.version;
        final String buildNumber = info.buildNumber;
        return Text(
          '${AppStrings.aboutVersionLabel} $version ($buildNumber)',
          style: AppTypography.createBody16(AppColors.grayMedium),
        );
      },
    );
  }
}

