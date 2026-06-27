import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../config/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).login(
      _correoCtrl.text.trim(),
      _passCtrl.text,
    );
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
              AppTheme.scaffoldBg,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Image.asset('assets/sia-logo.png',
                        width: 128, height: 128,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text('SIA - UAGRM',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                      const SizedBox(height: 6),
                      Text('Sistema de Gestion Academica',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 15,
                        )),
                      const SizedBox(height: 48),
                      GlassCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _correoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Correo electronico',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Ingrese su correo' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscurePass,
                              decoration: InputDecoration(
                                labelText: 'Contrasena',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                border: const OutlineInputBorder(),
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePass
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(
                                      () => _obscurePass = !_obscurePass),
                                ),
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Ingrese su contrasena' : null,
                              onFieldSubmitted: (_) => _login(),
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              label: 'Iniciar sesion',
                              loading: auth.loading,
                              onPressed: _login,
                              icon: Icons.login_rounded,
                            ),
                            if (auth.error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                      size: 20, color: Theme.of(context).colorScheme.error),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(auth.error!,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onErrorContainer,
                                          fontSize: 13,
                                        )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
