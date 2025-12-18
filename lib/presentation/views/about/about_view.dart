import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../views/webview/webview_view.dart';
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
              const SizedBox(height: 54),
              _buildLegalLinks(),
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

  Widget _buildLegalLinks() {
    final List<Map<String, String>> legalLinks = <Map<String, String>>[
      <String, String>{
        'title': 'ПОЛИТИКА КОНФИДЕНЦИАЛЬНОСТИ',
        'url': 'https://mopup.ru/police',
      },
      <String, String>{
        'title': 'СТАНДАРТЫ КАЧЕСТВА',
        'url': 'https://mopup.ru/standart',
      },
      <String, String>{
        'title': 'ДОГОВОР ВОЗМЕЗДНОГО ОКАЗАНИЯ УСЛУГ (ОФЕРТА ЗАКАЗЧИКА)',
        'url': 'https://mopup.ru/agreement',
      },
      <String, String>{
        'title': 'СОГЛАСИЕ НА ОБРАБОТКУ ПЕРСОНАЛЬНЫХ ДАННЫХ',
        'url': 'https://mopup.ru/person',
      },
      <String, String>{
        'title': 'УСЛОВИЯ ИСПОЛЬЗОВАНИЯ СЕРВИСА',
        'url': 'https://mopup.ru/service-offer',
      },
      <String, String>{
        'title': 'ОФЕРТА БЕЗОПАСНАЯ СДЕЛКА',
        'url': 'https://mopup.ru/offer',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Юридическая информация',
          style: AppTypography.createTitle20(AppColors.grayDark),
        ),
        const SizedBox(height: 22),
        ...legalLinks.map(
          (Map<String, String> link) => _buildLegalLinkItem(
            title: link['title']!,
            url: link['url']!,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalLinkItem({
    required String title,
    required String url,
  }) {
    return InkWell(
      onTap: () {
        HapticUtils.executeSelectionClick();
        Get.to<dynamic>(
          () => WebViewView(
            url: url,
            title: title,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: AppTypography.createBody13(AppColors.grayDark),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.grayMedium,
            ),
          ],
        ),
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

