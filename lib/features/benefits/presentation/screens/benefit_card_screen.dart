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

  Future<void> _launch(BuildContext context) async {
    final docSearch = user?.docSearch ?? '';
    final uri = Uri.parse(ExternalLinks.carnetDigital(docSearch));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Ver carnet digital en el navegador',
      button: true,
      child: InkWell(
        onTap: () => _launch(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          height: MediaQuery.orientationOf(context) == Orientation.portrait
              ? MediaQuery.sizeOf(context).height * 0.25
              : MediaQuery.sizeOf(context).height * 0.35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: cs.primary.withValues(alpha: 0.08),
            border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.credit_card_outlined, size: 60, color: cs.primary),
              const SizedBox(height: 8),
              Text(
                'Ver carnet digital',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
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
