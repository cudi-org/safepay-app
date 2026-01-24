import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BiometricAuthService {
  final LocalAuthentication _auth;

  BiometricAuthService() : _auth = LocalAuthentication();

  Future<bool> authenticate({required String reason}) async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        // En un caso real, aquí deberíamos permitir fallback a PIN del sistema o PIN de la app
        // Por ahora, asumimos que si no hay biometric, devolvemos false (o true si es simulador)
        print('Biometría no disponible en este dispositivo');
        return false; 
      }

      final isAuthenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Permite PIN del dispositivo si falla la huella
          useErrorDialogs: true,
        ),
      );

      return isAuthenticated;
    } on PlatformException catch (e) {
      print('Error en autenticación biometría: $e');
      return false;
    }
  }
}

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});
