import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_app/core/auth/biometrics_service.dart';
import 'package:mr_app/core/di/settings_providers.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/platform/app_platform.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_radius.dart';
import 'package:mr_app/core/theme/app_spacing.dart';
import 'package:mr_app/core/widgets/carbon_inline_notification.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey         = GlobalKey<FormState>();
  final _docController   = TextEditingController();
  final _birthController = TextEditingController();

  bool   _rememberMe      = true;
  bool   _hasSubmitted    = false;
  String? _errorMessage;
  bool   _canUseBiometrics = false;
  bool   _isLoggingIn      = false;

  late AnimationController _entryCtrl;
  late Animation<double>   _entryFade;
  late Animation<Offset>   _entrySlide;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    unawaited(_entryCtrl.forward());
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    unawaited(_loadSavedDoc());
    _docController.addListener(_clearError);
    _birthController.addListener(_clearError);
  }

  Future<void> _loadSavedDoc() async {
    final notifier = ref.read(authProvider.notifier);
    final savedDoc   = await notifier.getSavedDocumentNumber();
    final savedBirth = await notifier.getSavedBirthDate();
    if (!mounted) return;
    setState(() {
      if (savedDoc   != null) _docController.text   = savedDoc;
      if (savedBirth != null) _birthController.text = savedBirth;
    });
    if (savedDoc != null && savedBirth != null) unawaited(_checkBiometrics());
  }

  Future<void> _checkBiometrics() async {
    final enabled = await ref.read(biometricsEnabledProvider.future);
    if (!enabled || !mounted) return;
    final avail = await ref.read(biometricsServiceProvider).checkAvailability();
    if (!mounted) return;
    if (avail == BiometricAvailability.available) {
      setState(() => _canUseBiometrics = true);
      unawaited(_triggerBiometric());
    }
  }

  Future<void> _triggerBiometric() async {
    final ok = await ref
        .read(biometricsServiceProvider)
        .authenticate(reason: 'Ingresa a tu cuenta Multimate');
    if (!mounted || !ok) return;
    await _runLogin();
  }

  void _clearError() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _docController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  // ── Date picker ─────────────────────────────────────────────────────────────
  Future<void> _pickBirthDate() async {
    var initial = DateTime(DateTime.now().year - 30);
    if (_birthController.text.length == 10) {
      final p = _birthController.text.split('/');
      initial = DateTime.tryParse('${p[2]}-${p[1]}-${p[0]}') ?? initial;
    }

    if (AppPlatform.isIOS) {
      await _pickDateCupertino(initial);
    } else {
      await _pickDateMaterial(initial);
    }
  }

  Future<void> _pickDateCupertino(DateTime initial) async {
    var selected = initial;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                CupertinoButton(
                  child: const Text('Seleccionar'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _applyDate(selected);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode:        CupertinoDatePickerMode.date,
                initialDateTime: initial,
                minimumDate: DateTime(1900),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (d) => selected = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateMaterial(DateTime initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    if (picked != null) _applyDate(picked);
  }

  void _applyDate(DateTime d) {
    _clearError();
    setState(() {
      _birthController.text =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    });
  }

  Future<void> _submit() async {
    setState(() { _errorMessage = null; _hasSubmitted = true; });
    if (!_formKey.currentState!.validate()) return;
    await _runLogin();
  }

  Future<void> _runLogin() async {
    try {
      setState(() => _isLoggingIn = true);
      await ref.read(authProvider.notifier).login(
            documentNumber: _docController.text.trim(),
            birthDate:      _birthController.text.trim(),
            rememberMe:     _rememberMe,
          );
    } on Object catch (err) {
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

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:            Colors.transparent,
        statusBarIconBrightness:   isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:  isDark ? AppColors.darkBackground : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    ref.listen(authProvider, (prev, next) {
      next.whenOrNull(
        data: (state) {
          if (state is AuthAuthenticated) {
            unawaited(HapticFeedback.mediumImpact());
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header con gradiente de marca ────────────────────────────────
          _LoginHeader(),
          // ── Formulario ───────────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl,
                  ),
                  child: _LoginForm(
                    formKey:        _formKey,
                    docController:  _docController,
                    birthController: _birthController,
                    rememberMe:     _rememberMe,
                    hasSubmitted:   _hasSubmitted,
                    errorMessage:   _errorMessage,
                    isLoggingIn:    _isLoggingIn,
                    canUseBiometrics: _canUseBiometrics,
                    onRememberMeChanged: (v) =>
                        setState(() => _rememberMe = v ?? true),
                    onPickDate:    _pickBirthDate,
                    onSubmit:      _submit,
                    onBiometric:   _triggerBiometric,
                    onDismissError: _clearError,
                    onCotizar:     _openCotizador,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 32, 24, 32),
      color: Colors.white,
      child: Column(
        children: [
          Image.asset(
            'assets/images/5_fit.png',
            height: 96,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            'MULTIRIESGOS',
            style: TextStyle(
              color:       Colors.black87,
              fontSize:    11,
              fontWeight:  FontWeight.w700,
              letterSpacing: 3.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Formulario ─────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.docController,
    required this.birthController,
    required this.rememberMe,
    required this.hasSubmitted,
    required this.errorMessage,
    required this.isLoggingIn,
    required this.canUseBiometrics,
    required this.onRememberMeChanged,
    required this.onPickDate,
    required this.onSubmit,
    required this.onBiometric,
    required this.onDismissError,
    required this.onCotizar,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController docController;
  final TextEditingController birthController;
  final bool  rememberMe;
  final bool  hasSubmitted;
  final String? errorMessage;
  final bool  isLoggingIn;
  final bool  canUseBiometrics;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;
  final VoidCallback onBiometric;
  final VoidCallback onDismissError;
  final VoidCallback onCotizar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Form(
      key: formKey,
      autovalidateMode: hasSubmitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Iniciar sesión',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ingresa tus datos para continuar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Documento
          TextFormField(
            controller: docController,
            keyboardType:   TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText:  'No. Documento',
              hintText:   'Digite número de documento',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Ingrese número de documento' : null,
          ),
          const SizedBox(height: AppSpacing.md),

          // Fecha de nacimiento
          TextFormField(
            controller: birthController,
            keyboardType:   TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [_DateInputFormatter()],
            decoration: InputDecoration(
              labelText:  'Fecha de nacimiento',
              hintText:   'dd/mm/aaaa',
              prefixIcon: const Icon(Icons.cake_outlined),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                tooltip: 'Seleccionar con calendario',
                onPressed: onPickDate,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingrese fecha de nacimiento';
              if (v.length < 10) return 'Fecha incompleta (dd/mm/aaaa)';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xs),

          // Recordar
          CheckboxListTile(
            value:    rememberMe,
            onChanged: onRememberMeChanged,
            title:    const Text('Recordar cliente'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Banner de error
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SizeTransition(
                sizeFactor: anim, axisAlignment: -1, child: child,
              ),
            ),
            child: errorMessage != null
                ? Padding(
                    key: const ValueKey('error-banner'),
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: CarbonInlineNotification(
                      kind:    CarbonNotificationKind.error,
                      title:   errorMessage!,
                      onClose: onDismissError,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-error')),
          ),

          // Botón principal
          _PrimaryButton(isLoggingIn: isLoggingIn, onPressed: onSubmit),

          // Biometría
          if (canUseBiometrics) ...[
            const SizedBox(height: AppSpacing.s04),
            _BiometricButton(isLoggingIn: isLoggingIn, onPressed: onBiometric),
          ],

          const SizedBox(height: AppSpacing.sectionGap),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Footer: cotizador
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Aún no tienes seguro? ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              GestureDetector(
                onTap: isLoggingIn ? null : onCotizar,
                child: Text(
                  'Cotiza aquí',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:      AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Botón principal ────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.isLoggingIn, required this.onPressed});
  final bool isLoggingIn;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoggingIn ? null : onPressed,
      child: isLoggingIn
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text('Verificando…'),
              ],
            )
          : const Text('Ingresar'),
    );
  }
}

// ── Botón biométrico ───────────────────────────────────────────────────────────

class _BiometricButton extends StatelessWidget {
  const _BiometricButton({required this.isLoggingIn, required this.onPressed});
  final bool isLoggingIn;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: isLoggingIn ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppPlatform.isIOS
                ? Icons.face_unlock_outlined
                : Icons.fingerprint,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            AppPlatform.isIOS
                ? 'Ingresar con Face ID / Touch ID'
                : 'Ingresar con biometría',
          ),
        ],
      ),
    );
  }
}

// ── Formatter ─────────────────────────────────────────────────────────────────

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
