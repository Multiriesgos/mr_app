import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BenefitCardScreen extends ConsumerWidget {
  const BenefitCardScreen({super.key});

  static void _shareCarnet(User user) {
    final url = ExternalLinks.carnetDigital(user.docSearch);
    SharePlus.instance.share(
      ShareParams(
        text: 'Carnet Digital — Multiriesgos\n'
            'Nombre: ${user.name}\n'
            'DUI: ${user.documentNumber}\n'
            '$url',
        subject: 'Carnet Digital Multiriesgos',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.sidebarBg,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  onBack: () => context.pop(),
                  onShare: user == null ? null : () => _shareCarnet(user),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (MediaQuery.orientationOf(context) == Orientation.portrait)
                          Text(
                            'Tu carnet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        const SizedBox(height: 8),
                        _CarnetButton(user: user),
                        const SizedBox(height: 16),
                        const _BenefitGrid(),
                        const SizedBox(height: 16),
                        _QrSection(user: user),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, this.onShare});
  final VoidCallback onBack;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          if (canPop)
            Semantics(
              label: 'Volver',
              button: true,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                tooltip: 'Volver',
              ),
            )
          else
            const SizedBox(width: 48),
          const Expanded(
            child: Text(
              'Mis beneficios',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onShare != null)
            Semantics(
              label: 'Compartir carnet',
              button: true,
              child: IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                tooltip: 'Compartir carnet',
              ),
            )
          else
            const SizedBox(width: 48),
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
  // Banda "Nombre:": y = 50..64,  valor empieza en x = 62 (+2px margen)
  static const double _kNombreLeft   = 62 / 331;
  static const double _kNombreTop    = 50 / 219;
  static const double _kNombreHeight = 14 / 219;

  // Banda "DUI:":    y = 69..84,  valor empieza en x = 41 (+2px margen)
  static const double _kDuiLeft   = 41 / 331;
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
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            height: 1,
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
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            height: 1,
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

// ─── QR del carnet ───────────────────────────────────────────────────────────

class _QrSection extends StatelessWidget {
  const _QrSection({required this.user});
  final User? user;

  static const _kQrSize = 148.0;

  @override
  Widget build(BuildContext context) {
    final docSearch = user?.docSearch ?? '';
    if (docSearch.isEmpty) return const SizedBox.shrink();

    final qrData = ExternalLinks.carnetDigital(docSearch);
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Código QR del carnet. Toca para ampliar.',
      button: true,
      child: GestureDetector(
        onTap: () => _showFullScreen(context, qrData),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppColors.shadowSm,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Column(
            children: [
              Text(
                'Tu código QR',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: QrImageView(
                  data: qrData,
                  size: _kQrSize,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.sidebarBg,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.sidebarBg,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.open_in_full_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Toca para ampliar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context, String data) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: data,
                size: 260,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.sidebarBg,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.sidebarBg,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Muestra este código para identificarte',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Grid de beneficios ───────────────────────────────────────────────────────

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
          color: AppColors.info,
          url: ExternalLinks.medic,
        ),
        SizedBox(height: 8),
        _BenefitTile(
          title: 'Club Ahorro',
          subtitle: 'Descuentos y beneficios',
          icon: Icons.savings_outlined,
          color: AppColors.accent,
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
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: '$title — $subtitle. Abrir en el navegador',
      button: true,
      child: Material(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _launch,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
              subtitle: Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: Icon(
                Icons.open_in_new_outlined,
                color: color.withValues(alpha: 0.60),
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
