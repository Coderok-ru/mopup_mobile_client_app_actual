import Flutter
import UIKit
import YandexMapsMobile
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    YMKMapKit.setLocale("ru_RU")
    YMKMapKit.setApiKey("55da3a31-a0c0-4799-86e7-1644e4d7a47a")
    // Firebase инициализируется в main.dart, здесь только настраиваем делегаты
    // Устанавливаем делегат для Firebase Messaging
    Messaging.messaging().delegate = self
    // Настраиваем центр уведомлений
    UNUserNotificationCenter.current().delegate = self
    // Регистрируем приложение для удаленных уведомлений
    // Разрешения запрашиваются в NotificationService через Flutter
    application.registerForRemoteNotifications()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Обработка успешной регистрации для удаленных уведомлений
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("📱 APNS токен получен: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    // Передаем APNS токен в Firebase Messaging
    // Firebase автоматически определит тип токена (sandbox/production) на основе конфигурации
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // Обработка ошибки регистрации для удаленных уведомлений
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Ошибка регистрации для удаленных уведомлений: \(error.localizedDescription)")
  }
  
  // Обработка получения удаленного уведомления, когда приложение на переднем плане
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    print("📱 Уведомление получено в foreground: \(userInfo)")
    // Показываем уведомление даже когда приложение на переднем плане
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .badge, .sound]])
    } else {
      completionHandler([[.alert, .badge, .sound]])
    }
  }
  
  // Обработка нажатия на уведомление
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("📱 Нажатие на уведомление: \(userInfo)")
    completionHandler()
  }
}

// Расширение для обработки обновления FCM токена
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔑 Firebase registration token: \(String(describing: fcmToken))")
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}
