import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_radius.dart';
import 'package:mr_app/core/theme/app_spacing.dart';
import 'package:mr_app/core/widgets/app_nav_bar.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';
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
        appBar: AppNavBar(
          title: 'Mis beneficios',
          leading: context.canPop() ? AppNavBarLeading.back : AppNavBarLeading.none,
          actions: [
            if (user != null)
              Semantics(
                label: 'Compartir carnet',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                  tooltip: 'Compartir carnet',
                  onPressed: () => _shareCarnet(user),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: RefreshIndicator(
              onRefresh: () => ref.read(productsProvider.notifier).reload(),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePaddingH, AppSpacing.pagePaddingH,
                  AppSpacing.pagePaddingH, AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (MediaQuery.orientationOf(context) == Orientation.portrait)
                      Text(
                        'Tu carnet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    _CarnetButton(user: user),
                    const SizedBox(height: AppSpacing.md),
                    const _BenefitGrid(),
                    const SizedBox(height: AppSpacing.md),
                    _QrSection(user: user),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Carnet ───────────────────────────────────────────────────────────────────

class _CarnetButton extends StatelessWidget {
  const _CarnetButton({required this.user});
  final User? user;

  static const double _kAspect    = 331 / 219;
  static const double _kNombreLeft   = 62 / 331;
  static const double _kNombreTop    = 50 / 219;
  static const double _kNombreHeight = 14 / 219;
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
              final w      = constraints.maxWidth;
              final h      = constraints.maxHeight;
              final bandH  = h * _kNombreHeight;
              final fontSize = (bandH * 0.62).clamp(8.0, 13.0);

              return ClipRRect(
                borderRadius: AppRadius.mdBR,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/Card-bg-1.png',
                      width:  w,
                      height: h,
                      fit:    BoxFit.fill,
                    ),
                    Positioned(
                      left:   w * _kNombreLeft,
                      top:    h * _kNombreTop,
                      right:  w * 0.04,
                      height: h * _kNombreHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          name,
                          style: TextStyle(
                            color:       Colors.white,
                            fontSize:    fontSize,
                            fontWeight:  FontWeight.w700,
                            height:      1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Positioned(
                      left:   w * _kDuiLeft,
                      top:    h * _kDuiTop,
                      right:  w * 0.04,
                      height: h * _kDuiHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          doc,
                          style: TextStyle(
                            color:       Colors.white,
                            fontSize:    fontSize,
                            fontWeight:  FontWeight.w700,
                            height:      1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Positioned(
                      right:  8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical:   3,
                        ),
                        decoration: BoxDecoration(
                          color:        Colors.black.withValues(alpha: 0.35),
                          borderRadius: AppRadius.pillBR,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new, color: Colors.white, size: 12),
                            SizedBox(width: 3),
                            Text(
                              'Ver carnet',
                              style: TextStyle(
                                color:       Colors.white,
                                fontSize:    11,
                                fontWeight:  FontWeight.w500,
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

// ─── Código QR ────────────────────────────────────────────────────────────────

class _QrSection extends StatelessWidget {
  const _QrSection({required this.user});
  final User? user;

  static const double _kQrSize = 148;

  @override
  Widget build(BuildContext context) {
    final docSearch = user?.docSearch ?? '';
    if (docSearch.isEmpty) return const SizedBox.shrink();

    final qrData = ExternalLinks.carnetDigital(docSearch);
    final cs     = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Código QR del carnet. Toca para ampliar.',
      button: true,
      child: GestureDetector(
        onTap: () => _showFullScreen(context, qrData),
        child: Container(
          decoration: BoxDecoration(
            color:        cs.surface,
            borderRadius: AppRadius.mdBR,
            border:       Border.all(color: AppColors.borderLight),
            boxShadow:    AppColors.shadowSm,
          ),
          padding: const EdgeInsets.symmetric(
            vertical:   AppSpacing.cardGap,
            horizontal: AppSpacing.md,
          ),
          child: Column(
            children: [
              Text(
                'Tu código QR',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.cardGap),
              Container(
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: AppRadius.smBR,
                ),
                padding: const EdgeInsets.all(6),
                child: QrImageView(
                  data:            qrData,
                  size:            _kQrSize,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color:    AppColors.sidebarBg,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color:           AppColors.sidebarBg,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.open_in_full_rounded,
                    size:  13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Toca para ampliar',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted),
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
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBR),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sectionGap, AppSpacing.sectionGap,
            AppSpacing.sectionGap, AppSpacing.pagePaddingH,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data:            data,
                size:            260,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color:    AppColors.sidebarBg,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color:           AppColors.sidebarBg,
                ),
              ),
              const SizedBox(height: AppSpacing.s04),
              Text(
                'Muestra este código para identificarte',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xs),
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
          title:    'Medic',
          subtitle: 'Telemedicina 24/7',
          icon:     Icons.medical_services_outlined,
          color:    AppColors.info,
          url:      ExternalLinks.medic,
        ),
        SizedBox(height: AppSpacing.sm),
        _BenefitTile(
          title:    'Club Ahorro',
          subtitle: 'Descuentos y beneficios',
          icon:     Icons.savings_outlined,
          color:    AppColors.accent,
          url:      ExternalLinks.clubahorro,
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

  final String   title;
  final String   subtitle;
  final IconData icon;
  final Color    color;
  final String   url;

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
      label:  '$title — $subtitle. Abrir en el navegador',
      button: true,
      child: Material(
        color:        color.withValues(alpha: 0.05),
        borderRadius: AppRadius.mdBR,
        child: InkWell(
          onTap:        _launch,
          borderRadius: AppRadius.mdBR,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdBR,
              border:       Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical:   AppSpacing.xs,
              ),
              leading: Container(
                width:  44,
                height: 44,
                decoration: BoxDecoration(
                  color:        color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBR,
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
                size:  18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
