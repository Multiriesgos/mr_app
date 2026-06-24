import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_spacing.dart';
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
  final _birthFocusNode = FocusNode();
  bool _rememberMe = true;
  bool _hasSubmitted = false;
  String? _errorMessage;

  final _birthMask = MaskTextInputFormatter(mask: '##/##/####');

  @override
  void initState() {
    super.initState();
    _loadSavedDoc();
    _docController.addListener(_clearError);
    _birthController.addListener(_clearError);
  }

  Future<void> _loadSavedDoc() async {
    final saved =
        await ref.read(authProvider.notifier).getSavedDocumentNumber();
    if (saved != null && mounted) {
      setState(() => _docController.text = saved);
    }
  }

  void _clearError() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  @override
  void dispose() {
    _docController.dispose();
    _birthController.dispose();
    _birthFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _errorMessage = null; _hasSubmitted = true; });
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          documentNumber: _docController.text.trim(),
          birthDate: _birthController.text.trim(),
          rememberMe: _rememberMe,
        );
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
        error: (err, _) {
          final msg = err is AppException
              ? err.message
              : 'Error de conexión. Intente de nuevo.';
          setState(() => _errorMessage = msg);
        },
      );
    });

    final isLoading = ref.watch(authProvider).isLoading;

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
                      textInputAction: TextInputAction.next,
                      onEditingComplete: _birthFocusNode.requestFocus,
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
                      focusNode: _birthFocusNode,
                      keyboardType: TextInputType.datetime,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () {
                        _birthFocusNode.unfocus();
                        _submit();
                      },
                      maxLength: 10,
                      inputFormatters: [_birthMask],
                      decoration: const InputDecoration(
                        labelText: 'Fecha de nacimiento',
                        hintText: 'dd/mm/aaaa',
                        prefixIcon: Icon(Icons.cake_outlined),
                        counterText: '',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Digite fecha de nacimiento';
                        }
                        if (v.length != 10) return 'Formato: DD/MM/AAAA';
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.cardGap,
                                  vertical: AppSpacing.s04,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.errorBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.error.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 1),
                                      child: Icon(
                                        Icons.error_rounded,
                                        color: AppColors.errorDark,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.errorDark,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _clearError,
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: AppColors.errorDark,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('no-error')),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
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
                    const SizedBox(height: AppSpacing.s04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Aún no tienes seguro? ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: isLoading ? null : _openCotizador,
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
