/// Badge semántico de estado de póliza.
/// Antes duplicado como _buildStatusChip y _buildStatusTag.
library;

import 'package:flutter/material.dart';
import 'package:mr_app/core/theme/app_radius.dart';
import 'package:mr_app/core/widgets/policy_utils.dart';

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({required this.date, this.showDays = true, super.key});

  final DateTime? date;
  final bool showDays;

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();
    final days   = date!.difference(DateTime.now()).inDays;
    final status = PolicyUtils.statusOf(date);

    final label = showDays ? status.label(days) : status.badgeLabel;
    final color = status.color;
    final bg    = status.bgColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: AppRadius.pillBR,
      ),
      child: Text(
        label,
        style: TextStyle(
          color:       color,
          fontSize:    11,
          fontWeight:  FontWeight.w700,
          height:      1.4,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// Variante compacta solo con punto de color — para uso en listas densas.
class AppStatusDot extends StatelessWidget {
  const AppStatusDot({required this.date, super.key});
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final status = PolicyUtils.statusOf(date);
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color:  status.color,
        shape:  BoxShape.circle,
      ),
    );
  }
}
