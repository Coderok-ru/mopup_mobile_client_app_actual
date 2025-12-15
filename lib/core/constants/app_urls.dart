/// Константы API.
class AppUrls {
  /// Базовый адрес API.
  static const String baseUrl = 'https://admin.mopup.ru';

  /// Путь получения списка городов.
  static const String cities = '/api/cities';

  /// Путь регистрации пользователя.
  static const String register = '/api/client/register';

  /// Путь авторизации пользователя.
  static const String login = '/api/client/login';

  /// Путь выхода из системы.
  static const String logout = '/api/client/logout';

  /// Путь получения профиля.
  static const String profile = '/api/client/profile';

  /// Путь обновления профиля.
  static const String updateProfile = '/api/client/update';

  /// Путь обновления токена устройства.
  static const String updateDeviceToken = '/api/client/update-device-token';

  /// Путь удаления аккаунта.
  static const String deleteAccount = '/api/client/delete-account';

  /// Путь получения шаблонов заказов.
  static const String orderTemplates = '/api/order-templates';

  /// Путь работы с банковскими картами клиента.
  static const String paymentCards = '/api/client/payment-cards';

  /// Путь установки карты по умолчанию.
  static String createPaymentCardDefaultPath(int cardId) {
    return '$paymentCards/$cardId/default';
  }

  /// Путь создания заказа.
  static const String createOrder = '/api/client/orders';

  /// Путь получения списка заказов.
  static const String getOrders = '/api/client/orders';

  /// Путь удаления заказа.
  static String createDeleteOrderPath(int orderId) {
    return '$getOrders/$orderId';
  }

  /// Путь работы с избранными клинерами.
  static const String favoriteCleaners = '/api/client/favorites/cleaners';

  /// Путь получения мобильных настроек приложения.
  static const String mobileSettings = '/api/client/mobile-settings';

  /// Путь отправки данных устройства для push-уведомлений.
  static const String playerId = '/api/client/player-id';
}
