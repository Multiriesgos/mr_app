import 'package:mr_app/features/notifications/domain/models/notification_payload.dart';

/// Interfaz de notificaciones push.
///
/// Para activar Firebase Cloud Messaging:
/// 1. Crear proyecto en console.firebase.google.com
/// 2. Agregar app Android (package: multiriesgos.multimate.app)
///    → descargar google-services.json → android/app/
/// 3. Agregar app iOS (bundle: com.multiriesgos.multimate)
///    → descargar GoogleService-Info.plist → ios/Runner/
/// 4. En pubspec.yaml agregar:
///      firebase_core: ^3.6.0
///      firebase_messaging: ^15.1.3
/// 5. En android/app/build.gradle (plugins): 'com.google.gms.google-services'
/// 6. En android/build.gradle (classpath): 'com.google.gms:google-services:4.4.x'
/// 7. Reemplazar [NotificationServiceStub] por [FirebaseNotificationService]
///    en [notificationServiceProvider]
abstract interface class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<String?> getDeviceToken();
  Stream<NotificationPayload> get onForegroundMessage;
}
