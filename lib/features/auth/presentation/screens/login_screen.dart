import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_notifier.dart';

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
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin:
            const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
        duration: const Duration(seconds: 4),
        content: _ErrorSnackContent(message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isLoading)
                Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  child: const LinearProgressIndicator(),
                ),
              SizedBox(height: size.height * 0.115),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 30, 30),
                child: Image.asset('assets/images/5_fit.png'),
              ),
              SizedBox(height: size.height * 0.025),
              const Text(
                'INGRESE AQUÍ',
                style: TextStyle(
                  color: Color.fromRGBO(23, 0, 147, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.045),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      _BorderedField(
                        controller: _docController,
                        labelText: 'No. Documento',
                        hintText: 'Digite número documento',
                        prefixIcon: Icons.person,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Ingrese número documento'
                            : null,
                      ),
                      SizedBox(height: size.height * 0.025),
                      _BorderedField(
                        controller: _birthController,
                        labelText: 'Fecha de nacimiento',
                        hintText: 'dd/mm/aaaa',
                        prefixIcon: Icons.lock,
                        keyboardType: TextInputType.datetime,
                        maxLength: 10,
                        inputFormatters: [_birthMask],
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Digite fecha de nacimiento';
                          }
                          if (v.length != 10) {
                            return 'Formato: DD/MM/AAAA';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.025),
                      CheckboxListTile(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? true),
                        title: const Text('Recordar cliente'),
                        activeColor: const Color.fromRGBO(23, 0, 147, 1),
                      ),
                      SizedBox(height: size.height * 0.025),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                child: ElevatedButton.icon(
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.shopping_cart),
                                  onPressed: isLoading ? null : _openCotizador,
                                  label: const Text('COTIZA',
                                      style: TextStyle(fontSize: 14)),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 56),
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                child: ElevatedButton.icon(
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.key),
                                  onPressed: isLoading ? null : _submit,
                                  label: const Text('INGRESAR',
                                      style: TextStyle(fontSize: 14)),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 56),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Campo de texto reutilizable con borde gris
class _BorderedField extends StatelessWidget {
  const _BorderedField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  static const _borderSide = BorderSide(
    color: Color.fromRGBO(84, 87, 90, 0.5),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon,
            color: const Color.fromRGBO(84, 87, 90, 0.5)),
        border: const OutlineInputBorder(borderSide: _borderSide),
        enabledBorder: const OutlineInputBorder(borderSide: _borderSide),
        focusedBorder: const OutlineInputBorder(borderSide: _borderSide),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// Contenido del SnackBar de error
class _ErrorSnackContent extends StatelessWidget {
  const _ErrorSnackContent({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 28),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Oops Error!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -18,
          left: 16,
          child: Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
            child: const Icon(Icons.clear_outlined,
                color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}
