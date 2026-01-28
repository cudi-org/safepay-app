import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/core/providers/global_providers.dart';
import 'package:safepay/features/activity/providers/activity_notifier.dart';
import 'package:safepay/features/settings/providers/settings_notifier.dart';

// --- WIDGETS AUXILIARES ---

// Elemento de una opción de Ajustes
class _SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// Botón de Cierre de Sesión
class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onLogout,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Logout',
                style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold)),
            Icon(Icons.logout, color: AppColors.danger),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL ---

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Muestra el modal de confirmación de desactivación de Gasless (Pág 27)
  void _showGaslessToggleModal(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Gas-Free Payments',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• By disabling this feature, you are responsible for paying the gas fees for each transaction.',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '• Your micropayments will no longer be fee-free and may incur gas fees for each subscription send or execution on the Arc Network.',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '• ATTENTION: Your recurring subscriptions may fail if your wallet does not have enough USDC to cover the gas fee at the time of execution.',
              style: const TextStyle(
                  color: AppColors.danger, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textPrimary)),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.toggleGasless(false);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child:
                const Text('Deactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Simulación de la función de cierre de sesión
  void _handleLogout(BuildContext context, WidgetRef ref) {
    // Simulación: resetear el estado de autenticación a falso
    ref.read(isAuthenticatedProvider.notifier).state = false;
    ref.read(hasBiometricsProvider.notifier).state = false;
    // Navegar de vuelta a la pantalla de autenticación (se maneja en routerProvider)
    context.goNamed(AppRoutes.pinAuthName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);
    final user = ref.watch(activityNotifierProvider.select((s) => s.user));
    final hasBiometrics = ref.watch(hasBiometricsProvider);

    // Icono de Avatar (simulación de Saitama - Pág 27)
    final Widget avatar = CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.primary,
      child: Text(user?.alias[1].toUpperCase() ?? 'S',
          style: const TextStyle(fontSize: 32, color: Colors.white)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con Botón de Cierre de Sesión (Pág 27)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => _handleLogout(context, ref),
                      child: const Icon(Icons.exit_to_app,
                          color: AppColors.danger, size: 30),
                    ),
                  ],
                ),
              ),

              // Avatar y Alias
              Center(
                child: Column(
                  children: [
                    avatar,
                    const SizedBox(height: 8),
                    Text(
                      'Personal',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- SECCIÓN PERSONAL ---
              _SettingsItem(
                title: 'Alias',
                subtitle: user?.alias ?? '@loading',
                trailing: const Icon(Icons.edit,
                    size: 16, color: AppColors.textSecondary),
                onTap: () {/* Lógica para cambiar alias */},
              ),
              _SettingsItem(
                title: 'PIN',
                subtitle: '******',
                onTap: () {/* Lógica para cambiar PIN */},
              ),
              _SettingsItem(
                title: 'Biometrics',
                trailing: Switch(
                  value: hasBiometrics,
                  onChanged: (val) {
                    ref
                        .read(settingsNotifierProvider.notifier)
                        .toggleBiometrics(val);
                    if (val) {
                      // Simular proceso de configuración de huella si se activa
                    }
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              _SettingsItem(
                title: 'Notifications',
                trailing: Switch(
                  value: state.isNotificationsEnabled,
                  onChanged: ref
                      .read(settingsNotifierProvider.notifier)
                      .toggleNotifications,
                  activeColor: AppColors.primary,
                ),
              ),

              const Divider(height: 30, thickness: 1),

              // --- SECCIÓN APP ---
              Padding(
                padding: const EdgeInsets.only(left: 24.0, bottom: 8),
                child: const Text('App',
                    style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold)),
              ),

              // Gasless (Pág 27)
              _SettingsItem(
                title: 'Gasless',
                subtitle: state.isGaslessEnabled ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: state.isGaslessEnabled,
                  onChanged: (val) {
                    if (!val) {
                      _showGaslessToggleModal(context, ref);
                    } else {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .toggleGasless(true);
                    }
                  },
                  activeColor: AppColors.primary,
                ),
              ),

              // Políticas
              _SettingsItem(
                title: 'Privacy Policy',
                onTap: () {
                  // Navegar a la pantalla de políticas de Onboarding (simulación)
                  context.pushNamed(AppRoutes.termsAndConditionsName);
                },
              ),

              // Exportar Datos
              _SettingsItem(
                title: 'Export Data',
                onTap: () {/* Lógica para exportar historial de Activity */},
              ),

              const Divider(height: 30, thickness: 1),

              // Botón de Cierre de Sesión
              _LogoutButton(onLogout: () => _handleLogout(context, ref)),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          CustomBottomNavBar(currentIndex: 2), // Pestaña Settings
    );
  }
}
