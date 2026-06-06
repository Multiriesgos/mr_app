import 'dart:async';

import 'package:mr_app/core/logging/app_logger.dart';
import 'package:mr_app/features/notifications/domain/models/notification_payload.dart';
import 'package:mr_app/features/notifications/domain/notification_service.dart';

/// Implementación stub — reemplazar por FirebaseNotificationService
/// una vez configurado el proyecto Firebase (ver instrucciones en
/// NotificationService).
class NotificationServiceStub implements NotificationService {
  final _controller = StreamController<NotificationPayload>.broadcast();

  @override
  Future<void> initialize() async {
    appLogger.info('notifications: stub — Firebase no configurado');
  }

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> getDeviceToken() async => null;

  @override
  Stream<NotificationPayload> get onForegroundMessage => _controller.stream;
}
