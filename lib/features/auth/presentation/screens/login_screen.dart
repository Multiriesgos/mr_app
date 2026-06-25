import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_app/core/auth/biometrics_service.dart';
import 'package:mr_app/core/di/settings_providers.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_spacing.dart';
import 'package:mr_app/core/widgets/carbon_inline_notification.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _docController = TextEditingController();
  final _birthController = TextEditingController();
  bool _rememberMe = true;
  bool _hasSubmitted = false;
  String? _errorMessage;
  bool _canUseBiometrics = false;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDoc();
    _docController.addListener(_clearError);
    _birthController.addListener(_clearError);
  }

  Future<void> _loadSavedDoc() async {
    final notifier = ref.read(authProvider.notifier);
    final savedDoc = await notifier.getSavedDocumentNumber();
    final savedBirth = await notifier.getSavedBirthDate();
    if (!mounted) return;
    setState(() {
      if (savedDoc != null) _docController.text = savedDoc;
      if (savedBirth != null) _birthController.text = savedBirth;
    });
    if (savedDoc != null && savedBirth != null) unawaited(_checkBiometrics());
  }

  Future<void> _checkBiometrics() async {
    final enabled = await ref.read(biometricsEnabledProvider.future);
    if (!enabled || !mounted) return;
    final availability =
        await ref.read(biometricsServiceProvider).checkAvailability();
    if (!mounted) return;
    if (availability == BiometricAvailability.available) {
      setState(() => _canUseBiometrics = true);
      unawaited(_triggerBiometric());
    }
  }

  Future<void> _triggerBiometric() async {
    final ok = await ref.read(biometricsServiceProvider).authenticate(
          reason: 'Ingresa a tu cuenta Multimate',
        );
    if (!mounted || !ok) return;
    try {
      setState(() => _isLoggingIn = true);
      await ref.read(authProvider.notifier).login(
            documentNumber: _docController.text.trim(),
            birthDate: _birthController.text.trim(),
            rememberMe: _rememberMe,
          );
    } catch (err) {
      if (!mounted) return;
      final msg = err is AppException
          ? err.message
          : 'Error de conexión. Intente de nuevo.';
      setState(() { _errorMessage = msg; _isLoggingIn = false; });
    }
  }

  void _clearError() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  @override
  void dispose() {
    _docController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    DateTime? initial;
    if (_birthController.text.length == 10) {
      final p = _birthController.text.split('/');
      initial = DateTime.tryParse('${p[2]}-${p[1]}-${p[0]}');
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime(DateTime.now().year - 30),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    if (picked == null || !mounted) return;
    _clearError();
    setState(() {
      _birthController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  Future<void> _submit() async {
    setState(() { _errorMessage = null; _hasSubmitted = true; });
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoggingIn = true);
      await ref.read(authProvider.notifier).login(
            documentNumber: _docController.text.trim(),
            birthDate: _birthController.text.trim(),
            rememberMe: _rememberMe,
          );
    } catch (err) {
      if (!mounted) return;
      final msg = err is AppException
          ? err.message
          : 'Error de conexión. Intente de nuevo.';
      setState(() { _errorMessage = msg; _isLoggingIn = false; });
    }
  }

  Future<void> _openCotizador() async {
    final uri = Uri.parse('https://multiriesgos.com/cotizador');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDark ? const Color(0xFF1A1F2E) : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    ref.listen(authProvider, (prev, next) {
      next.whenOrNull(
        data: (state) {
          if (state is AuthAuthenticated) {
            HapticFeedback.mediumImpact();
          }
        },
      );
    });

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Image.asset('assets/images/5_fit.png'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Iniciar sesión',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ingresa tus datos para continuar',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Form(
                key: _formKey,
                autovalidateMode: _hasSubmitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _docController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'No. Documento',
                        hintText: 'Digite número de documento',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Ingrese número de documento'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _birthController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [_DateInputFormatter()],
                      decoration: InputDecoration(
                        labelText: 'Fecha de nacimiento',
                        hintText: 'dd/mm/aaaa',
                        prefixIcon: const Icon(Icons.cake_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today_outlined),
                          tooltip: 'Seleccionar con calendario',
                          onPressed: _pickBirthDate,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese fecha de nacimiento';
                        if (v.length < 10) return 'Fecha incompleta (dd/mm/aaaa)';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (v) =>
                          setState(() => _rememberMe = v ?? true),
                      title: const Text('Recordar cliente'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: child,
                        ),
                      ),
                      child: _errorMessage != null
                          ? Padding(
                              key: const ValueKey('error-banner'),
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: CarbonInlineNotification(
                                kind: CarbonNotificationKind.error,
                                title: _errorMessage!,
                                onClose: _clearError,
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('no-error')),
                    ),
                    ElevatedButton(
                      onPressed: _isLoggingIn ? null : _submit,
                      child: _isLoggingIn
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Verificando...'),
                              ],
                            )
                          : const Text('Ingresar'),
                    ),
                    if (_canUseBiometrics) ...[
                      const SizedBox(height: AppSpacing.s04),
                      OutlinedButton.icon(
                        onPressed: _isLoggingIn ? null : _triggerBiometric,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Ingresar con biometría'),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Aún no tienes seguro? ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: _isLoggingIn ? null : _openCotizador,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Cotiza aquí',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
