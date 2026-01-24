import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';

class AppRoutes {
  // Rutas principales de navegación (Paths)
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
  static const String notifications = '/notifications';

  // Rutas de Features (Paths)
  static const String bulutChat = '/chat';
  static const String activity = '/activity';

  // Rutas de Envío (Paths anidadas)
  static const String sendSafe = '/send';
  static const String sendDetails = '/send/details';
  static const String sendAuth = '/send/auth';

  // Nombres de las rutas (Names) para uso con GoRouter.goNamed()
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
  static const String notificationsName = 'notifications';

  static const String chatName = 'chat';
  static const String activityName = 'activity';

  // Nombres de rutas de Envío
  static const String sendSafeName = 'sendSafe';
  static const String sendDetailsName = 'sendDetails';
  static const String sendAuthName = 'sendAuth';

  // ... todo tu código de AppRoutes (líneas 1-56) está perfecto ...
}

// ======================================================
// SOLUCIÓN: Pegamos la barra de navegación aquí
// ======================================================

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Usamos un Padding para separar la barra de los bordes
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        // 2. Separado de abajo (usando la 'safe area' por si hay notch)
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Container(
        height: 70, // Altura fija
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          // 3. El color de fondo que pediste
          color: const Color(0xFF1E2A38),
          // 4. Totalmente redondeado
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: Icons.home_filled, // Relleno
              outlineIcon: Icons.home_outlined, // Contorno
              isSelected: currentIndex == 0,
              onTap: () => GoRouter.of(context).goNamed(AppRoutes.activityName),
            ),
            _NavBarItem(
              icon: Icons.cloud, // Relleno
              outlineIcon: Icons.cloud_outlined, // Contorno
              isSelected: currentIndex == 1,
              onTap: () => GoRouter.of(context).goNamed(AppRoutes.chatName),
            ),
            _NavBarItem(
              icon: Icons.settings, // Relleno
              outlineIcon: Icons.settings_outlined, // Contorno
              isSelected: currentIndex == 2,
              onTap: () => GoRouter.of(context).goNamed(AppRoutes.settingsName),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de icono actualizado
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData outlineIcon;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavBarItem(
      {required this.icon,
      required this.outlineIcon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? icon : outlineIcon,
              // 5. Color inactivo ahora es blanco semitransparente
              color: isSelected ? AppColors.primary : Colors.white60,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
