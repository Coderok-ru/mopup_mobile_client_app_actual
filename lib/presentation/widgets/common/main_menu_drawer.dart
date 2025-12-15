import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../controllers/auth_controller.dart';
import '../../../data/models/auth/user_entity.dart';
import '../../../routes/app_routes.dart';

/// Боковое меню с навигацией по разделам.
class MainMenuDrawer extends StatelessWidget {
  /// Создает боковое меню приложения.
  const MainMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute;
    final AuthController authController = Get.find<AuthController>();
    final double drawerWidth = MediaQuery.of(context).size.width * (2 / 3);
    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: AppColors.background,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final UserEntity? user = authController.currentUser.value;
                  final String initials = user?.getInitials() ?? '--';
                  final String? avatarUrl = user?.avatarUrl;
                  final String fullName = user?.getFullName() ?? 'Гость';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      _DrawerAvatar(avatarUrl: avatarUrl, initials: initials),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        textAlign: TextAlign.start,
                        style: AppTypography.createBody16(AppColors.grayMedium),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _allMenuItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final MenuItemData item = _allMenuItems[index];
                    final bool isSelected = currentRoute == item.route;
                    return _MenuDrawerItem(item: item, isSelected: isSelected);
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 72,
                  width: double.infinity,
                  child: SvgPicture.asset(AppAssets.logo, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;

  const _DrawerAvatar({required this.avatarUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    final String? resolvedUrl = _resolveAvatarUrl(avatarUrl);
    final bool hasAvatar = resolvedUrl != null && resolvedUrl.isNotEmpty;
    if (!hasAvatar) {
      return _InitialsCircle(initials: initials);
    }
    return ClipOval(
      child: Image.network(
        resolvedUrl,
        key: ValueKey<String>(resolvedUrl),
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        errorBuilder: (_, Object error, __) {
          debugPrint('Не удалось загрузить аватар $resolvedUrl: $error');
          return _InitialsCircle(initials: initials);
        },
        loadingBuilder:
            (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }
              return SizedBox(
                width: 92,
                height: 92,
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
      ),
    );
  }

  String? _resolveAvatarUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }
    if (url.startsWith('http')) {
      return url;
    }
    final String normalized = url.startsWith('/') ? url : '/$url';
    return '${AppUrls.baseUrl}$normalized';
  }
}

class _InitialsCircle extends StatelessWidget {
  final String initials;

  const _InitialsCircle({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.createTitle20(AppColors.grayDark),
        ),
      ),
    );
  }
}

class _MenuDrawerItem extends StatelessWidget {
  final MenuItemData item;
  final bool isSelected;

  const _MenuDrawerItem({required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _handleTap();
        },
        child: SizedBox(
          height: 48,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      item.title,
                      textAlign: TextAlign.right,
                      style: AppTypography.createBody16(
                        AppColors.grayDark,
                      ).copyWith(fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 8,
                  height: double.infinity,
                  color: isSelected
                      ? AppColors.accentGreen
                      : AppColors.mainPink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    Get.back();
    if (!isSelected) {
      Get.toNamed(item.route);
    }
  }
}

/// Данные пункта меню бокового дравера.
class MenuItemData {
  /// Заголовок пункта меню.
  final String title;

  /// Путь маршрута.
  final String route;

  /// Создает модель пункта меню.
  const MenuItemData({required this.title, required this.route});
}

const List<MenuItemData> _menuItems = <MenuItemData>[
  MenuItemData(title: AppStrings.menuPersonalAccount, route: AppRoutes.account),
  MenuItemData(title: AppStrings.menuRating, route: AppRoutes.rating),
  // MenuItemData(title: AppStrings.menuPayment, route: AppRoutes.payment),
  MenuItemData(title: AppStrings.menuOrders, route: AppRoutes.orders),
  MenuItemData(title: AppStrings.menuFavorites, route: AppRoutes.favorites),
];

const List<MenuItemData> _secondaryMenuItems = <MenuItemData>[
  MenuItemData(title: AppStrings.menuSettings, route: AppRoutes.settings),
  MenuItemData(title: AppStrings.menuAbout, route: AppRoutes.about),
];

const List<MenuItemData> _allMenuItems = <MenuItemData>[
  ..._menuItems,
  ..._secondaryMenuItems,
];
