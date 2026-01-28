import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/providers/global_providers.dart';
import 'package:safepay/core/constants/app_colors.dart';

// --- CLIPPERS ---

// Curva "Montaña" (Hill) para la cabecera
// El área blanca sube en el medio
class _OnboardingHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.85); // Empieza abajo a la izquierda

    // Curva cuadrática simple hacia arriba y luego abajo
    path.quadraticBezierTo(
      size.width / 2, size.height * 0.65, // Punto de control (arriba centro)
      size.width, size.height * 0.85, // Punto final (abajo derecha)
    );

    path.lineTo(size.width, 0); // Sube a la derecha
    path.lineTo(0, 0); // Vuelve a la izquierda
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Curva Inversa para el "Welcome" (El verde está abajo, con forma de montaña arriba)
class _WelcomeBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height * 0.15); // Empezar un poco abajo

    // Curva hacia arriba
    path.quadraticBezierTo(
      size.width / 2, -size.height * 0.05, // Punto de control (arriba, fuera)
      size.width, size.height * 0.15, // Final derecha
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- WIDGETS COMUNES ---

// Botón de Onboarding
class _OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
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
        // disabledBackgroundColor: AppColors.disabled,
        minimumSize: const Size(140, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Pill shape
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

// Cabecera Verde Curva
class _OnboardingHeader extends StatelessWidget {
  final String title;
  const _OnboardingHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _OnboardingHeaderClipper(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        width: double.infinity,
        color: AppColors.primary,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- PANTALLAS ---

// Pantalla 1: Welcome (Página 1, pero actualizada al screenshot)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Espacio Superior (Blanco)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Outline Azul/Morado (según screenshot)
                  Icon(Icons.cloud_queue_rounded,
                      size: 100, color: AppColors.accent),
                  const SizedBox(height: 16),
                  // Texto CUDI SafePay
                  const Text('CUDI SafePay',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),

          // Área Inferior Verde Curva
          ClipPath(
            clipper: _WelcomeBottomClipper(),
            child: Container(
              color: AppColors.primary,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(32, 80, 32, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors
                            .textPrimary, // Screenshot muestra texto oscuro sobre verde?
                        // No, en screenshot 1: "Welcome" es NEGRO sobre VERDE?
                        // Espera, screenshot 1 muestra fondo verde abajo. Texto "Welcome" es NEGRO.
                        // Texto "Welcome to SafePay..." es NEGRO.
                      )),
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome to SafePay,\nwe're glad you're here.",
                    style:
                        TextStyle(fontSize: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _OnboardingButton(
                        text: 'Log In',
                        onPressed: () =>
                            context.goNamed(AppRoutes.termsAndConditionsName),
                        backgroundColor: AppColors.accent, // Purple
                        foregroundColor: Colors.white,
                      ),
                      _OnboardingButton(
                        text: 'Sign Up',
                        onPressed: () =>
                            context.goNamed(AppRoutes.termsAndConditionsName),
                        backgroundColor: AppColors.textPrimary, // Dark Grey
                        foregroundColor: Colors.white,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla Unificada de Seguridad y Términos (Wizard / Carousel)
// Maneja las 4 pantallas: Safety, Terms 1, Terms 2, Checkboxes
class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Estados Checkbox
  bool _isOver18 = false;
  bool _agreedToPolicy = false;

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Finalizar -> Ir a Configurar Acceso
      context.goNamed(AppRoutes.configureAccessName);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Título dinámico según la página
    String title = _currentPage == 0 ? 'Safety first' : 'Terms and\nconditions';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Cabecera Común
          _OnboardingHeader(title: title),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              physics:
                  const NeverScrollableScrollPhysics(), // Bloquear swipe manual si se desea
              children: [
                // STEP 1: Safety First
                _SimpleContentPage(
                  content:
                      "No one but you will be able to access your information. You'll need to create or import a wallet.",
                  onContinue: _nextPage,
                ),
                // STEP 2: Terms - Simplicity
                _SimpleContentPage(
                  content:
                      "The simplicity of the Cloud for transferring your money. Pay, subscribe, and manage your Funds without hidden fees or the complexity of private keys.",
                  onContinue: _nextPage,
                ),
                // STEP 3: Terms - Notice
                _NoticePage(onContinue: _nextPage),

                // STEP 4: Checkboxes
                _CheckboxesPage(
                  isOver18: _isOver18,
                  agreedToPolicy: _agreedToPolicy,
                  onOver18Changed: (v) => setState(() => _isOver18 = v!),
                  onPolicyChanged: (v) => setState(() => _agreedToPolicy = v!),
                  onContinue: (_isOver18 && _agreedToPolicy) ? _nextPage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget genérico para contenido + botón Continue
class _SimpleContentPage extends StatelessWidget {
  final String content;
  final VoidCallback onContinue;

  const _SimpleContentPage({required this.content, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, color: AppColors.textPrimary, height: 1.5),
          ),
          const Spacer(flex: 2),
          _OnboardingButton(
            text: 'Continue',
            onPressed: onContinue,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Página de "Important Notice"
class _NoticePage extends StatelessWidget {
  final VoidCallback onContinue;
  const _NoticePage({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('IMPORTANT NOTICE:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors
                      .textPrimary)), // Screenshot shows dark bold text for title
          const SizedBox(height: 16),
          const Text(
            'CUDI SafePay is NOT a bank. You retain full control of your Funds (non-custodial).',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, color: AppColors.textPrimary, height: 1.5),
          ),
          const Spacer(),
          _OnboardingButton(
            text: 'Continue',
            onPressed: onContinue,
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Página de Checkboxes
class _CheckboxesPage extends StatelessWidget {
  final bool isOver18;
  final bool agreedToPolicy;
  final ValueChanged<bool?> onOver18Changed;
  final ValueChanged<bool?> onPolicyChanged;
  final VoidCallback? onContinue;

  const _CheckboxesPage({
    required this.isOver18,
    required this.agreedToPolicy,
    required this.onOver18Changed,
    required this.onPolicyChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _CheckboxRow(
            value: isOver18,
            onChanged: onOver18Changed,
            text:
                'I declare that I am over 18 years of age and understand that blockchain transactions are irreversible.',
          ),
          const SizedBox(height: 24),
          _CheckboxRow(
            value: agreedToPolicy,
            onChanged: onPolicyChanged,
            text: 'I agree to the Terms of Service and Privacy Policy.',
          ),
          const Spacer(),
          _OnboardingButton(
            text: 'Continue',
            onPressed: onContinue,
            // Screenshot 5 shows Blue button when active?
            // Or Grey when inactive.
            backgroundColor:
                onContinue != null ? AppColors.accent : AppColors.disabled,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;

  const _CheckboxRow(
      {required this.value, required this.onChanged, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// Pantalla 4: Configure Access (Se mantiene similar pero con el nuevo Header)
class ConfigureAccessScreen extends StatelessWidget {
  const ConfigureAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _OnboardingHeader(title: 'Configure\nyour access'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.goNamed(AppRoutes.pinSetupName),
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
                    onPressed: null,
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
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
