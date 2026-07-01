import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/auth/biometrics_service.dart';
import 'package:mr_app/core/di/settings_providers.dart';
import 'package:mr_app/core/logging/app_logger.dart';
import 'package:mr_app/core/platform/app_platform.dart';
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
  DateTime? _backgroundedAt;
  StreamSubscription<NotificationPayload>? _notifSubscription;

  static const _kBiometricTimeoutSeconds = 300;
  final List<ScrollController> _scrollControllers =
      List.generate(4, (_) => ScrollController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initNotifications());
  }

  @override
  void dispose() {
    unawaited(_notifSubscription?.cancel());
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
        unawaited(
          c.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
      }
    } else {
      setState(() => _currentIndex = i);
    }
  }

  Future<void> _initNotifications() async {
    await ref.read(localNotificationServiceProvider).initialize();
    final service = ref.read(notificationServiceProvider);
    await service.initialize();
    final granted = await service.requestPermission();

    if (granted) {
      final authState = ref.read(authProvider).value;
      if (authState is AuthAuthenticated) {
        final docTopic =
            'doc_${authState.user.documentNumber.replaceAll(RegExp('[^a-zA-Z0-9]'), '_')}';
        await FirebaseMessaging.instance.subscribeToTopic(docTopic);
        appLogger.info('notifications: suscrito al topic "$docTopic"');
      }
    }

    if (!mounted) return;

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null && mounted) _handleNotifNavigation(initial.data);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (mounted) _handleNotifNavigation(message.data);
    });

    _notifSubscription = service.onForegroundMessage.listen(_showNotifBanner);
  }

  void _handleNotifNavigation(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route != null && mounted) {
      unawaited(context.push(route));
    } else if (mounted) {
      setState(() => _currentIndex = 0);
    }
  }

  void _showNotifBanner(NotificationPayload payload) {
    if (!mounted) return;

    unawaited(
      ref.read(localNotificationServiceProvider).showNow(
            id: DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
            title: payload.title,
            body: payload.body,
          ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payload.title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
            Text(payload.body, style: const TextStyle(color: Colors.white70)),
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
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final enabled = ref.read(biometricsEnabledProvider).value ?? false;
      if (enabled) _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final at = _backgroundedAt;
      _backgroundedAt = null;
      if (at != null) {
        final elapsed = DateTime.now().difference(at).inSeconds;
        if (elapsed >= _kBiometricTimeoutSeconds) {
          unawaited(_runBiometricCheck());
        }
      }
    }
  }

  Future<void> _runBiometricCheck() async {
    final ok = await ref
        .read(biometricsServiceProvider)
        .authenticate(reason: 'Verifica tu identidad para continuar');
    if (!ok && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).value;
    final user = authState is AuthAuthenticated ? authState.user : null;

    ref.listen<AsyncValue<List<Product>>>(productsProvider, (_, next) {
      next.whenData((products) {
        unawaited(
          scheduleRenewalReminders(
            products,
            ref.read(localNotificationServiceProvider),
          ),
        );
      });
    });

    final products = ref.watch(productsProvider).value ?? [];
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
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: tabs[_currentIndex],
        ),
      ),
      bottomNavigationBar: _buildTabBar(urgentCount),
    );
  }

  Widget _buildTabBar(int urgentCount) {
    // ── iOS: CupertinoTabBar nativo ────────────────────────────────────────
    if (AppPlatform.isIOS) {
      final cs = Theme.of(context).colorScheme;
      return CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        backgroundColor: cs.surface,
        activeColor: AppColors.primary,
        inactiveColor: AppColors.textMuted,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5),),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.creditcard),
            activeIcon: Icon(CupertinoIcons.creditcard_fill),
            label: 'Carnet',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: urgentCount > 0 && _currentIndex != 2,
              label: urgentCount > 9 ? const Text('9+') : Text('$urgentCount'),
              child: const Icon(CupertinoIcons.doc_text),
            ),
            activeIcon: Badge(
              isLabelVisible: urgentCount > 0 && _currentIndex != 2,
              label: urgentCount > 9 ? const Text('9+') : Text('$urgentCount'),
              child: const Icon(CupertinoIcons.doc_text_fill),
            ),
            label: 'Pólizas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: 'Perfil',
          ),
        ],
      );
    }

    // ── Android: BottomNavigationBar Material ──────────────────────────────
    return BottomNavigationBar(
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
    );
  }
}
