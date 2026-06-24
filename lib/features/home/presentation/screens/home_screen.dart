import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/auth/biometrics_service.dart';
import 'package:mr_app/core/di/settings_providers.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/benefits/presentation/screens/benefit_card_screen.dart';
import 'package:mr_app/features/home/presentation/screens/home_tab.dart';
import 'package:mr_app/features/home/presentation/screens/profile_screen.dart';
import 'package:mr_app/features/notifications/di/notification_providers.dart';
import 'package:mr_app/features/notifications/domain/models/notification_payload.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/domain/usecases/schedule_renewal_reminders.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';
import 'package:mr_app/features/products/presentation/screens/products_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _needsBiometricCheck = false;
  StreamSubscription<NotificationPayload>? _notifSubscription;
  final List<ScrollController> _scrollControllers =
      List.generate(4, (_) => ScrollController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initNotifications();
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTap(int i) {
    if (i == _currentIndex) {
      final c = _scrollControllers[i];
      if (c.hasClients) {
        c.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else {
      setState(() => _currentIndex = i);
    }
  }

  Future<void> _initNotifications() async {
    final service = ref.read(notificationServiceProvider);
    await service.initialize();
    await service.requestPermission();

    if (!mounted) return;

    // App abierta desde tap en notificación (app terminada).
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null && mounted) _handleNotifNavigation(initial.data);

    // Tap en notificación con app en background.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (mounted) _handleNotifNavigation(message.data);
    });

    // Mensajes mientras la app está en primer plano.
    _notifSubscription = service.onForegroundMessage.listen(_showNotifBanner);
  }

  /// Navega a la ruta indicada en el payload o al tab Inicio por defecto.
  void _handleNotifNavigation(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route != null && mounted) {
      context.push(route);
    } else if (mounted) {
      setState(() => _currentIndex = 0);
    }
  }

  void _showNotifBanner(NotificationPayload payload) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payload.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              payload.body,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        action: payload.route != null
            ? SnackBarAction(
                label: 'Ver',
                textColor: Colors.white,
                onPressed: () => context.push(payload.route!),
              )
            : null,
        backgroundColor: AppColors.sidebarBg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final biometricsEnabled =
          ref.read(biometricsEnabledProvider).valueOrNull ?? false;
      if (biometricsEnabled) _needsBiometricCheck = true;
    } else if (state == AppLifecycleState.resumed && _needsBiometricCheck) {
      _needsBiometricCheck = false;
      _runBiometricCheck();
    }
  }

  Future<void> _runBiometricCheck() async {
    final biometricsService = ref.read(biometricsServiceProvider);
    final ok = await biometricsService.authenticate(
      reason: 'Verifica tu identidad para continuar',
    );
    if (!ok && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState is AuthAuthenticated ? authState.user : null;

    ref.listen<AsyncValue<List<Product>>>(productsProvider, (_, next) {
      next.whenData((products) {
        final svc = ref.read(localNotificationServiceProvider);
        scheduleRenewalReminders(products, svc);
      });
    });

    final products = ref.watch(productsProvider).valueOrNull ?? [];
    final urgentCount = products.where((p) {
      if (p.fechaRenovacion == null) return false;
      return p.fechaRenovacion!.difference(DateTime.now()).inDays <= 30;
    }).length;

    final tabs = <Widget>[
      PrimaryScrollController(
        controller: _scrollControllers[0],
        child: HomeTab(
          user: user,
          onTabChange: (i) => setState(() => _currentIndex = i),
        ),
      ),
      PrimaryScrollController(
        controller: _scrollControllers[1],
        child: const BenefitCardScreen(),
      ),
      PrimaryScrollController(
        controller: _scrollControllers[2],
        child: const ProductsScreen(),
      ),
      PrimaryScrollController(
        controller: _scrollControllers[3],
        child: const ProfileScreen(),
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: tabs[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Carnet',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: urgentCount > 0 && _currentIndex != 2,
              label: urgentCount > 9 ? const Text('9+') : Text('$urgentCount'),
              child: const Icon(Icons.description_outlined),
            ),
            activeIcon: const Icon(Icons.description),
            label: 'Pólizas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
