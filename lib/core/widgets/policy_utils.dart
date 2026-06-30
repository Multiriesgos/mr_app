/// Utilidades compartidas para tarjetas de póliza.
/// Centraliza `colorForRamo`, `iconForRamo` y `PolicyStatus`.
/// Antes duplicados en products_screen y product_detail_screen.
library;

import 'package:flutter/material.dart';
import 'package:mr_app/core/theme/app_colors.dart';

// ── Status ────────────────────────────────────────────────────────────────────

enum PolicyStatus { vigente, proxima, critica, vencida, sinFecha }

extension PolicyStatusX on PolicyStatus {
  Color get color => switch (this) {
    PolicyStatus.vigente  => AppColors.success,
    PolicyStatus.proxima  => AppColors.info,
    PolicyStatus.critica  => AppColors.statWarning,
    PolicyStatus.vencida  => AppColors.error,
    PolicyStatus.sinFecha => AppColors.textMuted,
  };

  Color get bgColor => switch (this) {
    PolicyStatus.vigente  => AppColors.successBg,
    PolicyStatus.proxima  => AppColors.infoBg,
    PolicyStatus.critica  => AppColors.warningBg,
    PolicyStatus.vencida  => AppColors.errorBg,
    PolicyStatus.sinFecha => AppColors.background,
  };

  String label(int days) => switch (this) {
    PolicyStatus.vencida  => 'Vencida hace ${(-days) == 1 ? "1 día" : "${-days} días"}',
    PolicyStatus.critica  => days == 0 ? '¡Vence hoy!' : 'Vence en $days d',
    PolicyStatus.proxima  => 'Vence en $days días',
    PolicyStatus.vigente  => 'Vigente',
    PolicyStatus.sinFecha => 'Sin fecha',
  };

  String get badgeLabel => switch (this) {
    PolicyStatus.vigente  => 'Vigente',
    PolicyStatus.proxima  => 'Por vencer',
    PolicyStatus.critica  => 'Urgente',
    PolicyStatus.vencida  => 'Vencida',
    PolicyStatus.sinFecha => '—',
  };
}

// ── Helpers ───────────────────────────────────────────────────────────────────

abstract final class PolicyUtils {
  static PolicyStatus statusOf(DateTime? fechaRenovacion) {
    if (fechaRenovacion == null) return PolicyStatus.sinFecha;
    final days = fechaRenovacion.difference(DateTime.now()).inDays;
    if (days < 0)   return PolicyStatus.vencida;
    if (days <= 7)  return PolicyStatus.critica;
    if (days <= 30) return PolicyStatus.proxima;
    return PolicyStatus.vigente;
  }

  static Color colorForRamo(String ramo) {
    final r = ramo.toLowerCase();
    if (r.contains('auto') || r.contains('veh')) return AppColors.info;
    if (r.contains('vida'))                       return AppColors.success;
    if (r.contains('salud') || r.contains('medic')) return AppColors.statSuccess;
    if (r.contains('incendio') || r.contains('hogar')) return AppColors.statWarning;
    return AppColors.primary;
  }

  static IconData iconForRamo(String ramo) {
    final r = ramo.toLowerCase();
    if (r.contains('auto') || r.contains('veh'))   return Icons.directions_car_outlined;
    if (r.contains('vida'))                         return Icons.favorite_border;
    if (r.contains('salud') || r.contains('medic')) return Icons.medical_services_outlined;
    if (r.contains('incendio') || r.contains('hogar')) return Icons.home_outlined;
    return Icons.description_outlined;
  }

  static String fmtDate(DateTime d) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
