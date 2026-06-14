import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_colors.dart';
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

  final _birthMask = MaskTextInputFormatter(mask: '##/##/####');

  @override
  void initState() {
    super.initState();
    _loadSavedDoc();
  }

  Future<void> _loadSavedDoc() async {
    final saved =
        await ref.read(authProvider.notifier).getSavedDocumentNumber();
    if (saved != null && mounted) {
      setState(() => _docController.text = saved);
    }
  }

  @override
  void dispose() {
    _docController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.errorBg,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorDark,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.errorDark,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

    ref.listen(authProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) {
          final msg = err is AppException
              ? err.message
              : 'Error de conexión. Intente de nuevo.';
          _showError(msg);
        },
      );
    });

    final isLoading = ref.watch(authProvider).isLoading;

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isLoading) const LinearProgressIndicator(),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Image.asset('assets/images/5_fit.png'),
              ),
              const SizedBox(height: 32),
              Text(
                'Iniciar sesión',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Ingresa tus datos para continuar',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _docController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'No. Documento',
                        hintText: 'Digite número de documento',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Ingrese número de documento'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthController,
                      keyboardType: TextInputType.datetime,
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
                    const SizedBox(height: 4),
                    CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (v) =>
                          setState(() => _rememberMe = v ?? true),
                      title: const Text('Recordar cliente'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Ingresar'),
                    ),
                    const SizedBox(height: 12),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
