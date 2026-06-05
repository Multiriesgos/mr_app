import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key, this.user});

  final User? user;

  Future<void> _call() async {
    final uri = Uri.parse(ExternalLinks.callCenter);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final name = user?.name ?? '';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido,',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            Text(
              name.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Llamar al centro de atención',
            button: true,
            child: IconButton(
              icon: Icon(Icons.support_agent_outlined, color: cs.primary),
              tooltip: 'Llamar al centro de atención',
              onPressed: _call,
            ),
          ),
          Semantics(
            label: 'Cerrar sesión',
            button: true,
            child: IconButton(
              icon: Icon(Icons.logout_outlined, color: cs.primary),
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
      body: const SafeArea(child: _HomeContent()),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/images/7_fit.png', height: 180),
            const SizedBox(height: 32),
            Text(
              'Bienvenido a Multimate',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu app de seguros y beneficios',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
