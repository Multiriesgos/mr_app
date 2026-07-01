import 'package:mr_app/features/notifications/domain/models/notification_payload.dart';

/// Interfaz de notificaciones push.
///
/// Implementación activa: `FirebaseNotificationService`, inyectada vía
/// `notificationServiceProvider` en `notification_providers.dart`.
abstract interface class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<String?> getDeviceToken();
  Stream<NotificationPayload> get onForegroundMessage;
}
