import 'package:flutter/material.dart';
import 'package:mr_app/core/theme/app_colors.dart';

/// Tipos semánticos de notificación Carbon v11.
enum CarbonNotificationKind { error, warning, success, info }

/// IBM Carbon Inline Notification (v11).
/// Acento izquierdo de 3px, fondo semántico, ícono 20px, sin border-radius.
/// https://carbondesignsystem.com/components/notification/usage/
class CarbonInlineNotification extends StatelessWidget {
  const CarbonInlineNotification({
    required this.kind,
    required this.title,
    this.subtitle,
    this.onAction,
    this.onClose,
    super.key,
  });

  final CarbonNotificationKind kind;
  final String title;
  final String? subtitle;

  /// Si se provee, toda la notificación se vuelve tappable y aparece ícono →
  final VoidCallback? onAction;

  /// Si se provee, muestra un botón X para cerrar la notificación.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final (bg, accent, fg, iconData) = _props();
    final body = Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, size: 20, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: fg.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new_outlined,
              size: 18,
              color: fg.withValues(alpha: 0.70),
            ),
          ],
          if (onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close_rounded, size: 18, color: fg.withValues(alpha: 0.70)),
            ),
          ],
        ],
      ),
    );

    if (onAction == null) return body;
    return Semantics(
      label: '$title${subtitle != null ? " — $subtitle" : ""}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onAction, child: body),
      ),
    );
  }

  (Color, Color, Color, IconData) _props() => switch (kind) {
    CarbonNotificationKind.error   => (
      AppColors.errorBg,
      AppColors.error,
      AppColors.errorDark,
      Icons.error_outline_rounded,
    ),
    CarbonNotificationKind.warning => (
      AppColors.warningBg,
      AppColors.warning,
      AppColors.warningDark,
      Icons.warning_amber_rounded,
    ),
    CarbonNotificationKind.success => (
      AppColors.successBg,
      AppColors.success,
      AppColors.successDark,
      Icons.check_circle_outline_rounded,
    ),
    CarbonNotificationKind.info    => (
      AppColors.infoBg,
      AppColors.info,
      AppColors.primary,
      Icons.info_outline_rounded,
    ),
  };
}
