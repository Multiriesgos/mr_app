import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class BenefitCardScreen extends ConsumerWidget {
  const BenefitCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 25),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(onBack: () => context.pop()),
                  const SizedBox(height: 25),
                  if (MediaQuery.orientationOf(context) == Orientation.portrait)
                    Text(
                      'Tu carnet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  const SizedBox(height: 8),
                  _CarnetButton(user: user),
                  const SizedBox(height: 16),
                  const _BenefitGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (canPop)
            Semantics(
              label: 'Volver',
              button: true,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.arrow_back_rounded, size: 24),
                ),
              ),
            )
          else
            const SizedBox(width: 32),
          Text(
            'Mis beneficios',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _CarnetButton extends StatelessWidget {
  const _CarnetButton({required this.user});
  final User? user;

  // Aspect ratio real de la imagen: 331 × 219 px
  static const double _kAspect = 331 / 219;

  // Posiciones medidas en píxeles sobre la imagen 331 × 219
  // Banda "Nombre:": y = 50..64,  valor empieza en x = 60
  static const double _kNombreLeft   = 60 / 331;
  static const double _kNombreTop    = 50 / 219;
  static const double _kNombreHeight = 14 / 219;

  // Banda "DUI:":    y = 69..84,  valor empieza en x = 39
  static const double _kDuiLeft   = 39 / 331;
  static const double _kDuiTop    = 69 / 219;
  static const double _kDuiHeight = 15 / 219;

  Future<void> _launch(BuildContext context) async {
    final docSearch = user?.docSearch ?? '';
    final uri = Uri.parse(ExternalLinks.carnetDigital(docSearch));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? '';
    final doc  = user?.documentNumber ?? '';

    return Semantics(
      label: 'Ver carnet digital en el navegador',
      button: true,
      child: GestureDetector(
        onTap: () => _launch(context),
        child: AspectRatio(
          aspectRatio: _kAspect,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final bandH = h * _kNombreHeight;
              final fontSize = (bandH * 0.62).clamp(8.0, 13.0);

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/Card-bg-1.png',
                      width: w,
                      height: h,
                      fit: BoxFit.fill,
                    ),
                    // Nombre sobre la banda naranja
                    Positioned(
                      left: w * _kNombreLeft,
                      top: h * _kNombreTop,
                      right: w * 0.04,
                      height: h * _kNombreHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          name,
                          style: TextStyle(
                            color: const Color(0xFF0D1B5E),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // DUI sobre la banda naranja
                    Positioned(
                      left: w * _kDuiLeft,
                      top: h * _kDuiTop,
                      right: w * 0.04,
                      height: h * _kDuiHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          doc,
                          style: TextStyle(
                            color: const Color(0xFF0D1B5E),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Botón "Ver carnet"
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new, color: Colors.white, size: 12),
                            SizedBox(width: 3),
                            Text(
                              'Ver carnet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BenefitGrid extends StatelessWidget {
  const _BenefitGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _BenefitTile(
          title: 'Medic',
          subtitle: 'Telemedicina 24/7',
          icon: Icons.medical_services_outlined,
          color: Colors.teal,
          url: ExternalLinks.medic,
        ),
        SizedBox(height: 8),
        _BenefitTile(
          title: 'Club Ahorro',
          subtitle: 'Descuentos y beneficios',
          icon: Icons.savings_outlined,
          color: Colors.orange,
          url: ExternalLinks.clubahorro,
        ),
      ],
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.url,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String url;

  Future<void> _launch() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title — $subtitle. Abrir en el navegador',
      button: true,
      child: ListTile(
        tileColor: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(icon, color: color, size: 36),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.open_in_new_outlined, color: color),
        onTap: _launch,
      ),
    );
  }
}
