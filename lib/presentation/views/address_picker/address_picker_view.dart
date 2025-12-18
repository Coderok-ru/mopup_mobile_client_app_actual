import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../controllers/address_picker_controller.dart';

/// Экран выбора адреса на карте.
class AddressPickerView extends GetView<AddressPickerController> {
  /// Создает экран выбора адреса.
  const AddressPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildMap(),
          _buildTopControls(),
          _buildCenterPin(),
          _buildReadyButton(),
          _buildSideControls(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return YandexMap(
      onMapCreated: controller.onMapCreated,
      onCameraPositionChanged:
          (CameraPosition position, CameraUpdateReason _, bool __) {
            controller.onCameraPositionChanged(position);
          },
      rotateGesturesEnabled: false,
      nightModeEnabled: false,
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.grayDark.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.close, color: AppColors.grayDark),
                ),
              ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.grayDark.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: controller.executeSearch,
                    icon: const Icon(Icons.search, color: AppColors.grayDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(
              () => Text(
                controller.address.value.isEmpty
                    ? 'Переместите карту для уточнения адреса'
                    : controller.address.value,
                style: (controller.address.value.isEmpty
                        ? AppTypography.createBody16(AppColors.grayLight)
                        : AppTypography.createTitle24(AppColors.grayDark)
                            .copyWith(fontSize: 26))
                    .copyWith(
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.white.withOpacity(0.9),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    Shadow(
                      color: Colors.white.withOpacity(0.7),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterPin() {
    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.string(
              _pinSvg,
              width: 48,
              height: 60,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyButton() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.grayDark,
            borderRadius: BorderRadius.circular(10),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.grayDark.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: TextButton(
              onPressed: controller.executeConfirmSelection,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Obx(
                () => controller.isFetchingAddress.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Готово',
                        style: AppTypography.createTitle20(AppColors.white),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideControls() {
    return Positioned(
      right: 24,
      bottom: 104,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _SideButton(
              icon: Icons.add,
              onPressed: controller.executeZoomIn,
            ),
            const SizedBox(height: 12),
            _SideButton(
              icon: Icons.remove,
              onPressed: controller.executeZoomOut,
            ),
            const SizedBox(height: 42),
            _SideButton(
              icon: Icons.my_location,
              onPressed: controller.executeCenterToCurrentLocation,
            ),
          ],
        ),
      ),
    );
  }
}
const String _pinSvg = '''
<svg width="64" height="78" viewBox="0 0 64 78" xmlns="http://www.w3.org/2000/svg">
  <path d="M32 74L13 38C10 33 8 27 8 21C8 10.402 16.88 2 27.6 2H36.4C47.12 2 56 10.402 56 21C56 27 54 33 51 38L32 74Z"
        fill="#ED8EAF" stroke="#121212" stroke-width="2" stroke-linejoin="round"/>
  <circle cx="32" cy="24" r="14" fill="#FFFFFF" stroke="#121212" stroke-width="2"/>
</svg>
''';

class _SideButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SideButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.grayDark.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.grayDark),
      ),
    );
  }
}


