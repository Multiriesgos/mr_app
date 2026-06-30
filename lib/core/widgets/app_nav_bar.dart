/// Barra de navegación adaptativa.
/// Reemplaza todos los _Header widgets custom y los AppBar directos en cada pantalla.
///
/// En iOS: muestra botón chevron + texto para "volver" (estilo HIG).
/// En Android: muestra arrow_back estándar Material.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/platform/app_platform.dart';
import 'package:mr_app/core/theme/app_colors.dart';

enum AppNavBarLeading {
  /// Sin botón de navegación — pantallas de tab root (Inicio, Perfil, etc.)
  none,
  /// Botón "volver" — pantallas push (detalle, beneficios, etc.)
  back,
  /// Botón "cerrar" — modales presentados con push
  close,
}

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavBar({
    this.title,
    this.titleWidget,
    this.leading = AppNavBarLeading.back,
    this.backLabel = 'Atrás',
    this.actions = const [],
    this.bottom,
    this.backgroundColor,
    this.height,
    super.key,
  }) : assert(
          title != null || titleWidget != null,
          'Provee title o titleWidget',
       );

  final String?  title;
  final Widget?  titleWidget;
  final AppNavBarLeading leading;
  final String   backLabel;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final Color?   backgroundColor;
  final double?  height;

  static const double _kBarHeight = kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
    (height ?? _kBarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.sidebarBg;

    return AppBar(
      backgroundColor:    bg,
      foregroundColor:    Colors.white,
      elevation:          0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading:      _buildLeading(context),
      leadingWidth: _leadingWidth,
      centerTitle:  leading != AppNavBarLeading.none,
      title:        titleWidget ?? Text(
        title!,
        style: const TextStyle(
          color:       Colors.white,
          fontSize:    17,
          fontWeight:  FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions,
      bottom: bottom ?? const _NavBorder(),
      toolbarHeight: height ?? _kBarHeight,
    );
  }

  // En iOS, el botón "atrás" ocupa más espacio horizontal (texto visible).
  double get _leadingWidth {
    if (leading == AppNavBarLeading.none) return 0;
    if (AppPlatform.isIOS && leading == AppNavBarLeading.back) {
      return (backLabel.length * 10.0 + 40).clamp(70.0, 120.0);
    }
    return kMinInteractiveDimension;
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading == AppNavBarLeading.none) return null;

    if (leading == AppNavBarLeading.close) {
      return IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => GoRouter.of(context).pop(),
        tooltip: 'Cerrar',
      );
    }

    // AppNavBarLeading.back
    if (AppPlatform.isIOS) {
      return CupertinoButton(
        padding: const EdgeInsets.only(left: 6),
        onPressed: () => GoRouter.of(context).pop(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.chevron_back,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 2),
            Text(
              backLabel,
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      label: 'Volver',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => GoRouter.of(context).pop(),
        tooltip: 'Volver',
      ),
    );
  }
}

/// Borde inferior sutil que reemplaza el Divider manual en las pantallas.
class _NavBorder extends StatelessWidget implements PreferredSizeWidget {
  const _NavBorder();
  @override
  Size get preferredSize => const Size.fromHeight(0.5);

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 0.5, thickness: 0.5, color: Colors.white12);
}
