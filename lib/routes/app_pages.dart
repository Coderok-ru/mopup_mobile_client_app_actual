import 'package:get/get.dart';

import '../presentation/bindings/auth_binding.dart';
import '../presentation/views/account/account_view.dart';
import '../presentation/views/auth/login_view.dart';
import '../presentation/views/auth/registration_view.dart';
import '../presentation/views/favorites/favorites_view.dart';
import '../presentation/views/info/info_view.dart';
import '../presentation/bindings/launch_binding.dart';
import '../presentation/views/launch/launch_view.dart';
import '../presentation/views/main/main_view.dart';
import '../presentation/views/orders/orders_view.dart';
import '../presentation/views/payment/payment_view.dart';
import '../presentation/views/rating/rating_view.dart';
import '../presentation/views/settings/settings_view.dart';
import '../presentation/views/about/about_view.dart';
import '../presentation/bindings/favorites_binding.dart';
import '../presentation/bindings/settings_binding.dart';
import '../presentation/bindings/rating_binding.dart';
import '../presentation/bindings/main_binding.dart';
import '../presentation/views/order_template/order_template_view.dart';
import '../presentation/bindings/order_template_binding.dart';
import '../presentation/views/order_schedule/order_schedule_view.dart';
import '../presentation/bindings/order_schedule_binding.dart';
import '../presentation/views/address_picker/address_picker_view.dart';
import '../presentation/bindings/address_picker_binding.dart';
import '../presentation/views/order_confirmation/order_confirmation_view.dart';
import '../presentation/bindings/payment_binding.dart';
import '../presentation/views/payment/add_payment_card_view.dart';
import '../presentation/bindings/add_payment_card_binding.dart';
import '../presentation/bindings/order_confirmation_binding.dart';
import '../presentation/bindings/orders_binding.dart';
import '../presentation/views/order_details/order_details_view.dart';
import '../presentation/bindings/order_details_binding.dart';
import '../presentation/bindings/info_binding.dart';
import '../presentation/views/offer/offer_view.dart';
import '../presentation/bindings/offer_binding.dart';
import 'app_routes.dart';
import 'middlewares/auth_guard.dart';

/// Определяет таблицу навигации приложения.
class AppPages {
  const AppPages._();

  /// Список страниц c привязкой зависимостей.
  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.launch,
      page: LaunchView.new,
      binding: LaunchBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.main,
      page: MainView.new,
      binding: MainBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: LoginView.new,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.registration,
      page: RegistrationView.new,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.account,
      page: AccountView.new,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.rating,
      page: RatingView.new,
      binding: RatingBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.orderTemplate,
      page: OrderTemplateView.new,
      binding: OrderTemplateBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.orderSchedule,
      page: OrderScheduleView.new,
      binding: OrderScheduleBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.orderConfirmation,
      page: OrderConfirmationView.new,
      binding: OrderConfirmationBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.addressPicker,
      page: AddressPickerView.new,
      binding: AddressPickerBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.payment,
      page: PaymentView.new,
      binding: PaymentBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.paymentAddCard,
      page: AddPaymentCardView.new,
      binding: AddPaymentCardBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.orders,
      page: OrdersView.new,
      binding: OrdersBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.orderDetails,
      page: OrderDetailsView.new,
      binding: OrderDetailsBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.favorites,
      page: FavoritesView.new,
      binding: FavoritesBinding(),
      middlewares: <GetMiddleware>[AuthGuard()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.settings,
      page: SettingsView.new,
      binding: SettingsBinding(),
    ),
    GetPage<dynamic>(name: AppRoutes.about, page: AboutView.new),
    GetPage<dynamic>(
      name: AppRoutes.info,
      page: InfoView.new,
      binding: InfoBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.offer,
      page: OfferView.new,
      binding: OfferBinding(),
    ),
  ];
}
