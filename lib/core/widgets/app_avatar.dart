/// Widget de avatar con iniciales reutilizable.
/// Antes duplicado en home_tab.dart y profile_screen.dart.
library;

import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.name,
    this.radius = 20,
    this.variant = AppAvatarVariant.nav,
    super.key,
  });

  const AppAvatar.profile({
    required this.name,
    this.radius = 46,
    super.key,
  }) : variant = AppAvatarVariant.profile;

  final String name;
  final double radius;
  final AppAvatarVariant variant;

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = switch (variant) {
      AppAvatarVariant.nav     => (Colors.white.withValues(alpha: 0.18), Colors.white),
      AppAvatarVariant.profile => (cs.primary.withValues(alpha: 0.12), cs.primary),
    };

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: name.isNotEmpty
          ? Text(
              initials(name),
              style: TextStyle(
                color:      fg,
                fontWeight: FontWeight.w700,
                fontSize:   (radius * 0.65).clamp(10.0, 32.0),
              ),
            )
          : Icon(Icons.person, size: radius, color: fg),
    );
  }
}

/// `nav` — para usar en AppBar (fondo translúcido blanco, texto blanco).
/// `profile` — para usar en ProfileScreen (fondo tintado primary, texto primary).
enum AppAvatarVariant { nav, profile }
