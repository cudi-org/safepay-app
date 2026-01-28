import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/core/providers/global_providers.dart'; // Replaces app_routes.dart

// --- WIDGETS DE ONBOARDING ---

class _CloudLogo extends StatelessWidget {
  const _CloudLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.cloud_queue_rounded,
        size: 80,
        color: AppColors.accent,
      ),
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _OnboardingButton({
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

// --- PANTALLAS DE LA SECUENCIA ---

// Pantalla 1: Bienvenida (Página 4)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Área de Logo y Título
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_queue, size: 120, color: AppColors.accent),
                const SizedBox(height: 16),
                Text(
                  'CUDI SafePay',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Área de Bienvenida y Botones (Estilo de tarjeta en la parte inferior)
          Container(
            padding: const EdgeInsets.all(32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Welcome to SafePay, we're glad you're here.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botón Log In (Simulamos un flujo que va a los términos)
                    _OnboardingButton(
                      text: 'Log In',
                      onPressed: () =>
                          context.goNamed(AppRoutes.termsAndConditionsName),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    // Botón Sign Up
                    _OnboardingButton(
                      text: 'Sign Up',
                      onPressed: () =>
                          context.goNamed(AppRoutes.termsAndConditionsName),
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla 2: Resumen de Seguridad y Condiciones (Página 5)
class SafetySummaryScreen extends StatelessWidget {
  const SafetySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety first',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No one but you will be able to access your information. You\'ll need to create or import a wallet.',
                style: TextStyle(
                    fontSize: 18, color: AppColors.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 32),
              const Text(
                'The simplicity of the Cloud for transferring your money. Pay, subscribe, and manage your funds without hidden fees or the complexity of private keys.',
                style: TextStyle(
                    fontSize: 18, color: AppColors.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bulutBubble,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IMPORTANT NOTICE:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.danger)),
                    const SizedBox(height: 4),
                    const Text(
                      'CUDI SafePay is NOT a bank. You retain full control of your funds (non-custodial).',
                      style:
                          TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      context.goNamed(AppRoutes.termsAndConditionsName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla 3: Términos y Condiciones (Página 6)
class TermsAndConditionsScreen extends ConsumerStatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  ConsumerState<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState
    extends ConsumerState<TermsAndConditionsScreen> {
  bool _isOver18 = false;
  bool _agreedToPolicy = false;

  void _checkContinue() {
    if (_isOver18 && _agreedToPolicy) {
      context.goNamed(AppRoutes.configureAccessName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _isOver18 && _agreedToPolicy;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Cabecera Verde Agua (Header)
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: AppColors.primary,
            child: const Center(
              child: Text(
                'Terms and\nconditions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Curva y Contenido
          Expanded(
            child: Stack(
              children: [
                // Curva de la Nube (Blanco)
                Positioned(
                  top: -50, // Ajuste para la curva
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: _CloudClipper(),
                    child: Container(
                      height: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20), // Espacio para la curva
                      _CheckboxRow(
                        value: _isOver18,
                        onChanged: (val) {
                          setState(() => _isOver18 = val ?? false);
                          _checkContinue();
                        },
                        text:
                            'I declare that I am over 18 years of age and understand that blockchain transactions are irreversible.',
                      ),
                      const SizedBox(height: 20),
                      _CheckboxRow(
                        value: _agreedToPolicy,
                        onChanged: (val) {
                          setState(() => _agreedToPolicy = val ?? false);
                          _checkContinue();
                        },
                        text:
                            'I agree to the Terms of Service and Privacy Policy.',
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canContinue ? _checkContinue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canContinue
                                ? AppColors.accent
                                : AppColors.disabled,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Continue',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para las filas de checkboxes
class _CheckboxRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;

  const _CheckboxRow({
    required this.value,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accent,
          checkColor: Colors.white,
          side: const BorderSide(color: AppColors.textSecondary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              text,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// Clipper para simular la curva de la nube (Página 6 y 7)
class _CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.5); // Start at mid-height
    path.cubicTo(
      size.width * 0.25, size.height * 0.1, // Control point 1 (left)
      size.width * 0.75, size.height * 0.9, // Control point 2 (right)
      size.width, size.height * 0.5, // End point
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Pantalla 4: Configurar Acceso (Página 7)
class ConfigureAccessScreen extends StatelessWidget {
  const ConfigureAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Cabecera Verde Agua (Header)
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: AppColors.primary,
            child: const Center(
              child: Text(
                'Configure\nyour access',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Curva de la Nube (Blanco)
          ClipPath(
            clipper: _CloudClipper(),
            child: Container(height: 100, color: Colors.white),
          ),
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context
                        .goNamed(AppRoutes.pinSetupName), // Flujo principal
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Create new wallet',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null, // Deshabilitado según el PDF
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.disabled,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Import with seed',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
