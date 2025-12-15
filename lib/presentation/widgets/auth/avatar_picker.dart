import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';

/// Виджет выбора аватара.
class AvatarPicker extends StatelessWidget {
  /// Данные изображения.
  final Uint8List? imageBytes;

  /// URL изображения.
  final String? imageUrl;

  /// Обработчик нажатия.
  final VoidCallback onTap;

  /// Обработчик удаления.
  final VoidCallback? onRemove;

  /// Размер виджета.
  final double size;

  /// Инициалы пользователя (используются в качестве заглушки).
  final String? initials;

  /// Создает виджет.
  const AvatarPicker({
    required this.imageBytes,
    required this.onTap,
    this.imageUrl,
    this.onRemove,
    this.size = 108,
    this.initials,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: size,
          width: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onTap,
                    child: Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grayLight.withValues(alpha: 0.2),
                      ),
                      child: ClipOval(child: _buildAvatarContent()),
                    ),
                  ),
                ),
              ),
              if ((imageBytes != null || imageUrl != null) && onRemove != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onRemove,
                      customBorder: const CircleBorder(),
                      child: Ink(
                        height: 28,
                        width: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.mainPink,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.avatarPlaceholder,
          style: AppTypography.createBody13(AppColors.grayMedium),
        ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, fit: BoxFit.cover);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder:
            (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: SizedBox(
                  width: size / 4,
                  height: size / 4,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    if (initials != null && initials!.isNotEmpty) {
      return Center(
        child: Text(
          initials!,
          style: AppTypography.createTitle20(AppColors.grayDark),
        ),
      );
    }
    return Center(
      child: Icon(
        Icons.photo_camera_outlined,
        size: size * 0.4,
        color: AppColors.grayMedium,
        weight: 0.5,
      ),
    );
  }
}
