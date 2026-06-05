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
import 'package:mr_app/features/products/presentation/screens/products_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  /// Verdadero cuando el app volvió del background y aún no se verificó.
  bool _needsBiometricCheck = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

    final tabs = <Widget>[
      HomeTab(user: user),
      const BenefitCardScreen(),
      const ProductsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0x8A000000),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Carnet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
