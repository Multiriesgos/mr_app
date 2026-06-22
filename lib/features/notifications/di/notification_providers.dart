import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_app/core/notifications/local_notification_service.dart';
import 'package:mr_app/features/notifications/data/firebase_notification_service.dart';
import 'package:mr_app/features/notifications/domain/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (_) => FirebaseNotificationService(),
);

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (_) => LocalNotificationService(),
);
