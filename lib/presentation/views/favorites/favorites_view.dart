import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../controllers/favorites_controller.dart';
import '../../widgets/common/main_menu_drawer.dart';
import '../../widgets/common/primary_app_bar.dart';

/// Экран избранных клинеров.
class FavoritesView extends GetView<FavoritesController> {
  /// Создает экран избранных клинеров.
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PrimaryAppBar(
        title: AppStrings.menuFavorites,
        canPop: true,
        hasMenu: true,
      ),
      endDrawer: const MainMenuDrawer(),
      endDrawerEnableOpenDragGesture: true,
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (controller.favoriteCleaners.isEmpty) {
            return _buildEmptyState();
          }
          return _buildList();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Вы ещё не добавили ни одного любимого клинера',
          textAlign: TextAlign.center,
          style: AppTypography.createBody16(AppColors.grayMedium),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemBuilder: (BuildContext context, int index) {
        final favorite = controller.favoriteCleaners[index];
        return _FavoriteCleanerCard(
          name: favorite.name,
          lastName: favorite.lastName,
          rating: favorite.rating,
          avatarUrl: favorite.profilePhotoUrl,
          cleanerId: favorite.id,
          onRemovePressed: () => controller.executeRemoveFromFavorites(
            favorite.id,
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 12);
      },
      itemCount: controller.favoriteCleaners.length,
    );
  }
}

/// Карточка любимого клинера.
class _FavoriteCleanerCard extends StatelessWidget {
  /// Идентификатор клинера.
  final int cleanerId;

  /// Имя клинера.
  final String name;

  /// Фамилия клинера.
  final String lastName;

  /// Рейтинг клинера.
  final double rating;

  /// URL аватара клинера.
  final String? avatarUrl;

  /// Обработчик удаления из избранных.
  final VoidCallback onRemovePressed;

  /// Создает карточку любимого клинера.
  const _FavoriteCleanerCard({
    required this.cleanerId,
    required this.name,
    required this.lastName,
    required this.rating,
    required this.avatarUrl,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$name $lastName',
                  style: AppTypography.createBody16(AppColors.grayDark),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTypography.createBody13(AppColors.grayMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              HapticUtils.executeSelectionClick();
              onRemovePressed();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mainPink,
            ),
            child: const Text('Убрать'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final String? url = avatarUrl;
    if (url == null || url.isEmpty) {
      return const CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.grayLight,
        child: Icon(
          Icons.person,
          color: AppColors.grayMedium,
        ),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.grayLight,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }
}

