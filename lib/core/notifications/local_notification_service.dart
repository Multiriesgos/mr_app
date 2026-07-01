import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mr_app/core/logging/app_logger.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _kChannelId = 'renewal_reminders';
const _kChannelName = 'Recordatorios de renovación';
const _kChannelDesc = 'Avisos cuando una póliza está próxima a vencer';

class LocalNotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _kChannelId,
            _kChannelName,
            description: _kChannelDesc,
            importance: Importance.high,
          ),
        );

    _initialized = true;
    appLogger.info('local_notifications: servicio inicializado');
  }

  Future<void> scheduleRenewalReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: _kChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.UTC),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    appLogger.info('local_notifications: programado id=$id para $scheduledDate');
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: _kChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    appLogger.info('local_notifications: todos los recordatorios cancelados');
  }
}
