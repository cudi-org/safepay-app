import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
// SOLUCIÓN 1: Se elimina la importación duplicada de 'app_routes.dart'
// import 'package:safepay/core/providers/global_providers.dart'; // Replaces app_routes.dart
import 'package:safepay/core/providers/global_providers.dart';

class BiometricsSetupScreen extends ConsumerWidget {
  const BiometricsSetupScreen({super.key});

  // Simula la configuración de la biometría y avanza al Home
  void _activateBiometrics(BuildContext context, WidgetRef ref) {
    // Lógica real: Llamada a LocalAuth para configurar
    // Por simplicidad, simulamos la activación y el avance
    ref.read(isAuthenticatedProvider.notifier).state = true;
    context.goNamed(AppRoutes.chatName);
  }

  // Si se presiona "Not now", simplemente avanza al Home
  void _skipBiometrics(BuildContext context, WidgetRef ref) {
    ref.read(isAuthenticatedProvider.notifier).state = true;
    context.goNamed(AppRoutes.chatName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header y Curva
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: AppColors.primary,
            child: const Center(
              child: Text(
                'Activate\nbiometrics?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ClipPath(
            clipper: _CloudClipper(), // <-- SOLUCIÓN 2 (Clase añadida abajo)
            child: Container(
                height: 100, color: AppColors.primary.withOpacity(0.01)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Text(
                  'You can use your fingerprint to enter faster.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, color: AppColors.textPrimary, height: 1.5),
                ),
                const SizedBox(height: 80),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _activateBiometrics(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Activate',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => _skipBiometrics(context, ref),
                  child: const Text(
                    'Not now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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

// --- PANTALLA DE AUTENTICACIÓN (LOGIN) ---

// Pantalla de Login con Biometría (Página 10)
class BiometricAuthScreen extends ConsumerWidget {
  const BiometricAuthScreen({super.key});

  void _authenticate(BuildContext context, WidgetRef ref) {
    // Simular autenticación exitosa
    ref.read(isAuthenticatedProvider.notifier).state = true;
    context.goNamed(AppRoutes.chatName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header y Curva
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: AppColors.primary,
            child: const Center(
              child: Text(
                'Pay Safe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ClipPath(
            clipper: _CloudClipper(), // <-- SOLUCIÓN 2 (Clase añadida abajo)
            child: Container(
                height: 100, color: AppColors.primary.withOpacity(0.01)),
          ),
          const Spacer(flex: 2),
          // Icono de Huella
          GestureDetector(
            onTap: () => _authenticate(context, ref),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textSecondary, width: 2),
              ),
              child: const Icon(Icons.fingerprint,
                  size: 80, color: AppColors.textPrimary),
            ),
          ),
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 50),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.goNamed(AppRoutes.pinAuthName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Login with PIN',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla de Login con PIN (Página 11)
class PinAuthScreen extends ConsumerStatefulWidget {
  const PinAuthScreen({super.key});

  @override
  ConsumerState<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends ConsumerState<PinAuthScreen> {
  final int pinLength = 6;
  String _pin = '';

  void _handlePinInput(String text) {
    if (_pin.length >= pinLength) return;
    setState(() {
      _pin = text;
      if (_pin.length == pinLength) {
        _authenticate();
      }
    });
  }

  void _handleBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _authenticate() async {
    // Simular validación del PIN
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Si el PIN es '111111', es exitoso
    if (_pin == '111111') {
      ref.read(isAuthenticatedProvider.notifier).state = true;
      context.goNamed(AppRoutes.chatName);
    } else {
      setState(() => _pin = '');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN incorrecto. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header y Curva
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: AppColors.primary,
            child: const Center(
              child: Text(
                'Pay Safe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ClipPath(
            clipper: _CloudClipper(), // <-- SOLUCIÓN 2 (Clase añadida abajo)
            child: Container(
                height: 100, color: AppColors.primary.withOpacity(0.01)),
          ),

          const Spacer(flex: 2),
          // PIN Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pinLength, (index) {
              return _PinInputBox(
                  filled: index <
                      _pin.length); // <-- SOLUCIÓN 3 (Clase añadida abajo)
            }),
          ),
          const Spacer(
              flex: 1), // Espacio extra para que el teclado no cubra el botón

          // Botón de Login (visible incluso con PIN incompleto, como en el diseño)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pin.length == pinLength ? _authenticate : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.disabled,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Login',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          const Spacer(),
          // Teclado Numérico
          _NumericKeypad(
            // <-- SOLUCIÓN 4 (Clase añadida abajo)
            onPinChanged: (digit) {
              if (_pin.length < pinLength) {
                _handlePinInput(_pin + digit);
              }
            },
            onBackspace: _handleBackspace,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

// =====================================================================
// SOLUCIÓN 2: CLASE '_CloudClipper' AÑADIDA
// =====================================================================
class _CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0); // Explicit start
    path.lineTo(0, size.height);

    // Split cubic into two quadratics for HTML renderer safety
    // First half: curve up
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.5,
    );
    // Second half: curve down
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.5,
    );

    path.lineTo(size.width, 0);
    path.lineTo(0, 0); // Explicit close properly
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// =====================================================================
// SOLUCIÓN 3: CLASE '_PinInputBox' AÑADIDA
// =====================================================================
class _PinInputBox extends StatelessWidget {
  final bool filled;
  const _PinInputBox({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: filled ? AppColors.textPrimary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textSecondary, width: 2),
      ),
    );
  }
}

// =====================================================================
// SOLUCIÓN 4: CLASES '_NumericKeypad' y '_KeypadButton' AÑADIDAS
// =====================================================================
class _NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onPinChanged;
  final VoidCallback onBackspace;

  const _NumericKeypad({
    required this.onPinChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _KeypadButton(text: '1', onPressed: () => onPinChanged('1')),
              _KeypadButton(text: '2', onPressed: () => onPinChanged('2')),
              _KeypadButton(text: '3', onPressed: () => onPinChanged('3')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _KeypadButton(text: '4', onPressed: () => onPinChanged('4')),
              _KeypadButton(text: '5', onPressed: () => onPinChanged('5')),
              _KeypadButton(text: '6', onPressed: () => onPinChanged('6')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _KeypadButton(text: '7', onPressed: () => onPinChanged('7')),
              _KeypadButton(text: '8', onPressed: () => onPinChanged('8')),
              _KeypadButton(text: '9', onPressed: () => onPinChanged('9')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(width: 60, height: 60), // Espacio vacío
              _KeypadButton(text: '0', onPressed: () => onPinChanged('0')),
              _KeypadButton(
                icon: Icons.backspace_outlined,
                onPressed: onBackspace,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  const _KeypadButton({
    this.text,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Center(
          child: text != null
              ? Text(
                  text!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                )
              : Icon(
                  icon,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
        ),
      ),
    );
  }
}
