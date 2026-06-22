import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mr_app/core/logging/app_logger.dart';
import 'package:mr_app/features/notifications/domain/models/notification_payload.dart';
import 'package:mr_app/features/notifications/domain/notification_service.dart';

/// Handler de mensajes en background — debe ser función top-level.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  appLogger.info('notifications: mensaje background — ${message.messageId}');
}

class FirebaseNotificationService implements NotificationService {
  final _controller = StreamController<NotificationPayload>.broadcast();
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    // iOS: mostrar banner/sonido/badge aunque la app esté en primer plano.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      appLogger.info('notifications: mensaje foreground — ${message.messageId}');
      final payload = _toPayload(message);
      if (payload != null) _controller.add(payload);
    });

    // Renovar suscripción al topic cuando el token FCM cambia.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      appLogger.info('notifications: token FCM renovado (${newToken.length} chars)');
      FirebaseMessaging.instance.subscribeToTopic('todos').then((_) {
        appLogger.info('notifications: re-suscrito al topic "todos"');
      });
    });

    appLogger.info('notifications: Firebase Messaging inicializado');
  }

  @override
  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    appLogger.info('notifications: permiso ${granted ? "concedido" : "denegado"}');

    if (granted) {
      // Suscribir al topic de broadcast para recibir notificaciones generales.
      await FirebaseMessaging.instance.subscribeToTopic('todos');
      appLogger.info('notifications: suscrito al topic "todos"');
    }

    return granted;
  }

  @override
  Future<String?> getDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      // No loguear el token completo (dato de identificación de device).
      appLogger.info('notifications: token FCM obtenido (${token?.length} chars)');
      return token;
    } on Exception catch (e, st) {
      appLogger.error('notifications: error obteniendo token', e, st);
      return null;
    }
  }

  @override
  Stream<NotificationPayload> get onForegroundMessage => _controller.stream;

  NotificationPayload? _toPayload(RemoteMessage message) {
    final title = message.notification?.title;
    final body = message.notification?.body;
    if (title == null || body == null) return null;

    // El backend puede incluir data['route'] = '/home/products/42' para deep-link.
    final route = message.data['route'] as String?;

    return NotificationPayload(
      title: title,
      body: body,
      data: Map<String, dynamic>.from(message.data),
      route: route,
    );
  }
}
