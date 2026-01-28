import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// SOLUCIÓN 1: Eliminado. AppRoutes se define en ESTE archivo, no se debe importar.
// import 'package:safepay/core/constants/app_routes.dart';
import 'package:safepay/features/onboarding/presentation/onboarding_screen.dart';
import 'package:safepay/features/onboarding/presentation/pin_setup_screen.dart';
// SOLUCIÓN 2: Eliminada la importación duplicada.
// import 'package:safepay/features/onboarding/presentation/pin_setup_screen.dart';
import 'package:safepay/features/bulut_chat/presentation/chat_screen.dart';
import 'package:safepay/features/send/presentation/send_safe_details_screen.dart';
// SOLUCIÓN 3: Eliminada la importación duplicada.
// import 'package:safepay/features/send/presentation/send_safe_details_screen.dart';
import 'package:safepay/features/send/presentation/send_auth_screen.dart';
// SOLUCIÓN 4: ¡ESTA ES LA IMPORTACIÓN QUE FALTABA!
import 'package:safepay/features/send/presentation/send_safe_screen.dart';
import 'package:safepay/features/activity/presentation/activity_screen.dart'; // Importación de la pantalla Activity
import 'package:safepay/features/settings/presentation/settings_screen.dart'; // Importación de la pantalla Settings
import 'package:safepay/features/settings/presentation/notifications_screen.dart'; // Importación de la pantalla Notifications
// SOLUCIÓN 5: Corregida la ruta (estaba en 'widgets/')
import 'package:safepay/features/onboarding/presentation/widgets/biometrics_setup_screen.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// ... (El resto de tu archivo está perfecto) ...
// Extendemos AppRoutes para incluir las nuevas rutas
class AppRoutes {
  // Rutas principales
  static const String root = '/';
  static const String welcome = '/welcome';
  static const String safetySummary = '/safety-summary';
  static const String termsAndConditions = '/terms';
  static const String configureAccess = '/configure-access';
  static const String pinSetup = '/pin-setup';
  static const String aliasSetup = '/alias-setup';
  static const String biometricsSetup = '/biometrics-setup';
  static const String biometricAuth = '/biometric-auth';
  static const String pinAuth = '/pin-auth';
  static const String settings = '/settings';
  static const String notifications = '/notifications'; // Nueva ruta

  // Rutas de Features
  static const String bulutChat = '/chat';
  static const String activity = '/activity';

  // Rutas de Envío
  static const String sendSafe = '/send';
  static const String sendDetails = '/send/details';
  static const String sendAuth = '/send/auth';

  // Nombres de las rutas para un manejo más limpio con GoRouter
  static const String welcomeName = 'welcome';
  static const String safetySummaryName = 'safetySummary';
  static const String termsAndConditionsName = 'termsAndConditions';
  static const String configureAccessName = 'configureAccess';
  static const String pinSetupName = 'pinSetup';
  static const String aliasSetupName = 'aliasSetup';
  static const String biometricsSetupName = 'biometricsSetup';
  static const String biometricAuthName = 'biometricAuth';
  static const String pinAuthName = 'pinAuth';
  static const String settingsName = 'settings';
  static const String notificationsName = 'notifications'; // Nuevo nombre

  static const String chatName = 'chat';
  static const String activityName = 'activity';

  // Nombres de rutas de Envío
  static const String sendSafeName = 'sendSafe';
  static const String sendDetailsName = 'sendDetails';
  static const String sendAuthName = 'sendAuth';
}

// === Custom Bottom Nav Bar (Centralizado) ===
// Este widget se mueve aquí para evitar errores de referencia circular
// en los archivos de las pestañas principales.

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
          top: 8, bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => GoRouter.of(context).goNamed(AppRoutes.activityName),
          ),
          _NavBarItem(
            icon: Icons.cloud,
            label: 'Bulut',
            isSelected: currentIndex == 1,
            onTap: () => GoRouter.of(context).goNamed(AppRoutes.chatName),
          ),
          _NavBarItem(
            icon: Icons.settings,
            label: 'Settings',
            isSelected: currentIndex == 2,
            onTap: () => GoRouter.of(context).goNamed(AppRoutes.settingsName),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavBarItem(
      {required this.icon,
      required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected ? AppColors.primary : AppColors.disabled,
              size: 28),
          Text(label,
              style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.disabled,
                  fontSize: 10)),
        ],
      ),
    );
  }
}
// === Fin de Custom Bottom Nav Bar ===

// Proveedor para el estado de autenticación (simulación de si el usuario ya hizo Onboarding)
// Por defecto, NO autenticado, para forzar el flujo de login/onboarding
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);
// Simulamos que el Onboarding (PIN/Alias) ya se hizo
final hasCompletedOnboardingProvider = StateProvider<bool>((ref) => false);
// Simulamos si el usuario ha activado la biometría
final hasBiometricsProvider = StateProvider<bool>((ref) => false);

// Proveedor de GoRouter para la navegación
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);
  final hasBiometrics = ref.watch(hasBiometricsProvider);

  return GoRouter(
    // La ruta inicial es la que forzará el flujo de Auth
    initialLocation: AppRoutes.welcome,

    // Lista de rutas
    routes: [
      // === Rutas de Onboarding (Flujo completo: Pags 4-9) ===
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRoutes.welcomeName,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsAndConditions,
        name: AppRoutes.termsAndConditionsName,
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.configureAccess,
        name: AppRoutes.configureAccessName,
        builder: (context, state) => const ConfigureAccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.pinSetup,
        name: AppRoutes.pinSetupName,
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.aliasSetup,
        name: AppRoutes.aliasSetupName,
        builder: (context, state) => const AliasSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.biometricsSetup,
        name: AppRoutes.biometricsSetupName,
        builder: (context, state) => const BiometricsSetupScreen(),
      ),

      // === Rutas de Autenticación (Pags 10-11) ===
      GoRoute(
        path: AppRoutes.biometricAuth,
        name: AppRoutes.biometricAuthName,
        builder: (context, state) => const BiometricAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.pinAuth,
        name: AppRoutes.pinAuthName,
        builder: (context, state) => const PinAuthScreen(),
      ),

      // === Rutas Principales (Pestañas) ===
      GoRoute(
        path: AppRoutes.bulutChat,
        name: AppRoutes.chatName,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.activity,
        name: AppRoutes.activityName,
        builder: (context, state) =>
            const ActivityScreen(), // Usamos la pantalla real
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settingsName,
        builder: (context, state) =>
            const SettingsScreen(), // Usamos la pantalla real
      ),

      // === Notificaciones (Modal de pantalla completa) ===
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notificationsName,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // === Rutas de Envío (Modales) ===
      GoRoute(
        path: AppRoutes.sendSafe,
        name: AppRoutes.sendSafeName,
        builder: (context, state) => const SendSafeScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.sendDetails.split('/').last, // details
            name: AppRoutes.sendDetailsName,
            builder: (context, state) => const SendSafeDetailsScreen(),
          ),
          GoRoute(
            path: AppRoutes.sendAuth.split('/').last, // auth
            name: AppRoutes.sendAuthName,
            builder: (context, state) => const SendAuthScreen(),
          ),
        ],
      ),
    ],

    // Redirección de rutas basada en el estado de autenticación y Onboarding
    redirect: (context, state) {
      final location = state.matchedLocation;
      final bool isAuthPath =
          location == AppRoutes.biometricAuth || location == AppRoutes.pinAuth;
      final bool isInitialOnboardingPath = location == AppRoutes.welcome ||
          location == AppRoutes.termsAndConditions ||
          location == AppRoutes.configureAccess;
      final bool isSetupPath = location == AppRoutes.pinSetup ||
          location == AppRoutes.aliasSetup ||
          location == AppRoutes.biometricsSetup;
      final bool isMainAppPath = location == AppRoutes.bulutChat ||
          location == AppRoutes.activity ||
          location == AppRoutes.settings ||
          location == AppRoutes.notifications;

      // 1. Si está autenticado, siempre va al chat si intenta entrar al Auth/Onboarding.
      if (isAuthenticated) {
        if (isAuthPath || isInitialOnboardingPath || isSetupPath) {
          return AppRoutes.bulutChat;
        }
        return null; // Continúa
      }

      // 2. Si NO está autenticado:
      // A. Si NO ha completado el Onboarding (PIN/Alias):
      if (!hasCompletedOnboarding) {
        if (isAuthPath || isMainAppPath) {
          // Si intenta ir a una pantalla de Auth/Chat/Activity, lo mandamos al inicio del Onboarding.
          return AppRoutes.welcome;
        }
        // Si ya está en una ruta de Onboarding, continúa.
        return null;
      }

      // B. Si SÍ completó Onboarding pero NO está autenticado (Login):
      if (hasCompletedOnboarding) {
        if (isMainAppPath || isSetupPath || isInitialOnboardingPath) {
          // Lo mandamos a la pantalla de Auth correspondiente
          return hasBiometrics ? AppRoutes.biometricAuth : AppRoutes.pinAuth;
        }
        // Si ya está en una ruta de Auth, continúa.
        return null;
      }

      return null;
    },
  );
});
