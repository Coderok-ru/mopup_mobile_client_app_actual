import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/bindings/global_binding.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_routes.dart';

/// Корневой виджет приложения.
class App extends StatelessWidget {
  /// Создает экземпляр приложения.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MopUp',
      theme: AppTheme.createLightTheme(),
      initialRoute: AppRoutes.launch,
      initialBinding: GlobalBinding(),
      getPages: AppPages.routes,
    );
  }
}
