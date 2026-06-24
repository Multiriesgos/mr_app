import 'package:flutter/material.dart';
import 'package:mr_app/core/theme/app_colors.dart';

/// Variantes semánticas del tag Carbon v11.
enum CarbonTagType { error, warning, success, info, gray }

/// IBM Carbon Tag — componente de etiqueta semántica (v11).
/// Pill shape (radius 100), height ~24px, font 12px/600.
/// https://carbondesignsystem.com/components/tag/usage/
class CarbonTag extends StatelessWidget {
  const CarbonTag({
    required this.label,
    this.type = CarbonTagType.gray,
    this.icon,
    this.onTap,
    super.key,
  });

  final String label;
  final CarbonTagType type;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors();
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.16,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(onTap: onTap, child: chip),
    );
  }

  (Color, Color) _colors() => switch (type) {
    CarbonTagType.error   => (AppColors.errorBg,   AppColors.errorDark),
    CarbonTagType.warning => (AppColors.warningBg,  AppColors.warningDark),
    CarbonTagType.success => (AppColors.successBg,  AppColors.successDark),
    CarbonTagType.info    => (AppColors.infoBg,     AppColors.info),
    CarbonTagType.gray    => (AppColors.background,  AppColors.textBody),
  };
}
