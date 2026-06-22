class NotificationPayload {
  const NotificationPayload({
    required this.title,
    required this.body,
    this.data = const {},
    this.route,
  });

  final String title;
  final String body;
  final Map<String, dynamic> data;

  /// Ruta GoRouter a la que navegar al tocar la notificación.
  /// El backend puede enviar p.ej. '/home/products/42' en data['route'].
  final String? route;
}
