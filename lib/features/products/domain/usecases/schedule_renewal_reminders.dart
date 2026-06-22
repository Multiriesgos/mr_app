import 'package:mr_app/core/notifications/local_notification_service.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';

Future<void> scheduleRenewalReminders(
  List<Product> products,
  LocalNotificationService service,
) async {
  await service.initialize();
  final now = DateTime.now();

  for (final p in products) {
    final due = p.fechaRenovacion;
    if (due == null) continue;

    final label = p.tipoSeguro.isNotEmpty ? p.tipoSeguro : p.ramo;

    final d30 = due.subtract(const Duration(days: 30));
    final d7 = due.subtract(const Duration(days: 7));

    if (d30.isAfter(now)) {
      await service.scheduleRenewalReminder(
        id: p.idRen * 10,
        title: 'Póliza próxima a vencer',
        body: '$label vence en 30 días',
        scheduledDate: d30,
      );
    }
    if (d7.isAfter(now)) {
      await service.scheduleRenewalReminder(
        id: p.idRen * 10 + 1,
        title: 'Póliza vence pronto',
        body: '$label vence en 7 días',
        scheduledDate: d7,
      );
    }
    if (due.isAfter(now)) {
      await service.scheduleRenewalReminder(
        id: p.idRen * 10 + 2,
        title: '¡Póliza vence hoy!',
        body: '$label vence hoy. Contactá a tu ejecutivo.',
        scheduledDate: due,
      );
    }
  }
}
