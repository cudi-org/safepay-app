import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/features/send/providers/send_notifier.dart';
import 'package:safepay/core/providers/global_providers.dart';
import 'package:safepay/utils/currency_formatter.dart';
import 'package:safepay/core/security/biometric_auth_service.dart'; // Importado
import 'package:safepay/core/security/secure_storage_service.dart'; // Importado
// Asumimos que _CloudClipper está en 'onboarding_screen.dart'
import 'package:safepay/features/onboarding/presentation/onboarding_screen.dart';

// --- WIDGETS AUXILIARES ---

// Reutilizamos el PinInputBox
class _PinInputBox extends StatelessWidget {
  final bool filled;
  const _PinInputBox({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: filled ? AppColors.textPrimary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textSecondary,
          width: 1.5,
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL ---

class SendAuthScreen extends ConsumerStatefulWidget {
  const SendAuthScreen({super.key});

  @override
  ConsumerState<SendAuthScreen> createState() => _SendAuthScreenState();
}

class _SendAuthScreenState extends ConsumerState<SendAuthScreen> {
  final int pinLength = 6;
  String _pin = '';
  bool _isPinMode = false;

  @override
  void initState() {
    super.initState();
    // Determinar el modo inicial (Huella si está activada, PIN si no)
    // Usamos un Future para evitar modificar el provider durante el build
    Future.delayed(Duration.zero, () {
      _isPinMode = !ref.read(hasBiometricsProvider);
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _togglePinMode() {
    setState(() {
      _isPinMode = true;
      _pin = '';
    });
  }

  void _handlePinInput(String key) {
    if (key == 'delete') {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    } else if (_pin.length < pinLength) {
      setState(() => _pin += key);
    }

    if (_pin.length == pinLength) {
      _confirmTransaction(usePin: true);
    }
  }

  void _confirmTransaction({bool usePin = false}) async {
    bool isAuthenticated = false;

    // 1. Autenticación
    if (usePin) {
      // Simulación de validación de PIN
      if (_pin == '111111') {
        isAuthenticated = true;
      } else {
        setState(() => _pin = '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN.')),
        );
        return;
      }
    } else {
      // Autenticación Biométrica Real
      final biometricService = ref.read(biometricAuthServiceProvider);
      isAuthenticated = await biometricService.authenticate(
        reason: 'Authenticate to confirm sending funds',
      );
      
      if (!isAuthenticated) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed.')),
        );
        return;
      }
    }

    if (isAuthenticated) {
      // 2. Llamar a la lógica de envío final (que usará el token seguro)
      final success = await ref
          .read(sendNotifierProvider.notifier)
          .confirmFinalTransaction();

      if (success && mounted) {
        // 3. Éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction successfully sent!')),
        );
        // 'AppRoutes' ahora es reconocido gracias a 'global_providers.dart'
        context.goNamed(AppRoutes.chatName);
      } else if (mounted) {
        // 4. Fallo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Transaction failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount =
        ref.watch(sendNotifierProvider.select((state) => state.amount));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: AppColors.primary,
            child: const Center(
              child: Text(
                'Send a Safe',
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

          // Envolvemos la parte central en Expanded y SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                   const SizedBox(height: 20),
                  Text(
                    'Sending ${CurrencyFormatter.formatYield(amount)} USDC',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                   const SizedBox(height: 10),
                  Text(
                    'Gas Rate: ${CurrencyFormatter.formatYield(0.0)} USDC',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This payment is commission-free. The Gasless feature covers the network fee.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),

                  // --- Contenido Dinámico de Autenticación (Página 23) ---
                  if (_isPinMode)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(pinLength, (index) {
                            return _PinInputBox(filled: index < _pin.length);
                          }),
                        ),
                        // Ajustamos el espacio para que quepa mejor
                        const SizedBox(height: 60),
                        ElevatedButton(
                          onPressed: _pin.length == pinLength
                              ? () => _confirmTransaction(usePin: true)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.disabled,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 80),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Confirm',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        // Huella (Simulación)
                        GestureDetector(
                          onTap: () => _confirmTransaction(usePin: false),
                          child: Container(
                             padding: const EdgeInsets.all(20),
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               border: Border.all(color: AppColors.primary, width: 2)
                             ),
                             child: const Icon(Icons.fingerprint,
                                size: 80, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                         const Text(
                          'Touch ID Sensor',
                           style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                         ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () => _togglePinMode(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                             elevation: 0,
                             side: const BorderSide(color: AppColors.textSecondary),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 30),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Use PIN instead',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  // --- Fin Contenido Dinámico ---
                  const SizedBox(height: 20), // Espacio al final del scroll
                ],
              ),
            ),
          ),

          // Si estamos en modo PIN, mostramos el teclado
          if (_isPinMode) _NumericKeypadAuth(onPinChanged: _handlePinInput),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

// Teclado Numérico Custom para PIN (reutilizado de pin_setup_screen.dart)
class _NumericKeypadAuth extends StatelessWidget {
  final ValueChanged<String> onPinChanged;

  const _NumericKeypadAuth({required this.onPinChanged});

  void _handleKeyPress(String key) {
    if (key == 'backspace') {
      onPinChanged('delete');
    } else {
      onPinChanged(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
              .map((key) => _KeypadButtonAuth(
                    text: key,
                    onPressed: () => _handleKeyPress(key),
                  )),
          const SizedBox.shrink(),
          _KeypadButtonAuth(text: '0', onPressed: () => _handleKeyPress('0')),
          _KeypadButtonAuth(
            icon: Icons.backspace_outlined,
            onPressed: () => _handleKeyPress('backspace'),
          ),
        ],
      ),
    );
  }
}

class _KeypadButtonAuth extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  const _KeypadButtonAuth({this.text, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 28, color: AppColors.textPrimary)
            : Text(
                text!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }
}

// =====================================================================
// SOLUCIÓN 2: CLASE '_CloudClipper' AÑADIDA
// (Copiada de 'onboarding_screen.dart' para que sea accesible)
// =====================================================================
class _CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Empezamos desde abajo a la izquierda, donde la curva termina
    path.lineTo(0, size.height);
    // Curva principal
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.1, // Curva hacia arriba
      size.width * 0.75,
      size.height * 0.9, // Curva hacia abajo
      size.width,
      size.height * 0.5, // Termina en la mitad derecha
    );
    // Línea hasta la esquina superior derecha
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
