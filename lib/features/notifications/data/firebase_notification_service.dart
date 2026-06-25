import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mr_app/core/logging/app_logger.dart';
import 'package:mr_app/features/notifications/domain/models/notification_payload.dart';
import 'package:mr_app/features/notifications/domain/notification_service.dart';

const _kChannelId = 'renewal_reminders';
const _kChannelName = 'Recordatorios de renovación';

/// Handler de mensajes en background — debe ser función top-level.
/// Solo se necesita para mensajes data-only; los que tienen campo
/// `notification` los muestra el sistema automáticamente.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  appLogger.info('notifications: mensaje background — ${message.messageId}');

  if (message.notification == null) {
    final title = message.data['title'] as String?;
    final body = message.data['body'] as String?;
    if (title == null || body == null) return;

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _kChannelId,
            _kChannelName,
            importance: Importance.high,
          ),
        );

    await plugin.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _kChannelId,
          _kChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
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
    // Soportar mensajes notification y data-only.
    final title =
        message.notification?.title ?? message.data['title'] as String?;
    final body =
        message.notification?.body ?? message.data['body'] as String?;
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
