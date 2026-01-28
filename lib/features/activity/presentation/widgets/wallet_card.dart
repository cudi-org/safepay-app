import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/core/providers/global_providers.dart'; // Replaces app_routes.dart
import 'package:safepay/features/activity/providers/activity_notifier.dart';

import 'package:qr_flutter/qr_flutter.dart'; // Importa el paquete para el QR

// --- WIDGETS AUXILIARES ---

// Icono de acción de la Wallet (Buy, Send, Receive)
class _WalletActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDisabled;

  const _WalletActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade200 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.1),
                        blurRadius: 6,
                      ),
                    ],
            ),
            child: Icon(
              icon,
              color: isDisabled ? AppColors.disabled : AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDisabled ? AppColors.disabled : AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// Menú de 3 Puntos (Página 17) - Simulación
class _WalletSettingsMenu extends StatelessWidget {
  const _WalletSettingsMenu();

  @override
  Widget build(BuildContext context) {
    // Simulación de un PopUp Menu
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) {
        // Lógica de navegación o acción
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Acción: $value')));
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'details',
          child: Text('Details'),
        ),
        const PopupMenuItem<String>(
          value: 'create',
          child: Text('Create new wallet'),
        ),
        const PopupMenuItem<String>(
          value: 'import',
          child: Text('Import new wallet'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete this wallet',
              style: TextStyle(color: AppColors.danger)),
        ),
      ],
    );
  }
}

// --- WIDGET PRINCIPAL: WALLET CARD ---

class WalletCard extends ConsumerStatefulWidget {
  const WalletCard({super.key});

  @override
  ConsumerState<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends ConsumerState<WalletCard> {
  // Alternar entre Balance (Pág 12) y QR (Pág 16)
  bool _showQrCode = false;

  void _toggleView() {
    setState(() {
      _showQrCode = !_showQrCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceFormatted = ref.watch(currentBalanceFormattedProvider);
    final walletAddress = ref.watch(activityNotifierProvider.select((state) =>
        state.user?.walletAddress ?? '0x00000000000000000000000000000000'));

    const cardColor = AppColors.textPrimary; // Gris oscuro

    return Column(
      children: [
        // 1. Tarjeta de Balance / QR
        GestureDetector(
          onTap: _toggleView,
          child: Container(
            height: 227,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              // ======================================================
              // SOLUCIÓN: Usamos AnimatedSwitcher para la animación
              // ======================================================
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  // Animación de Fade (puedes cambiarla por un 'Flip' si prefieres)
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _showQrCode
                    // --- VISTA TRASERA (QR) ---
                    ? Stack(
                        // Key única para que el Switcher sepa que es un widget diferente
                        key: const ValueKey(true),
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/back_wallet.png', // <-- Tu nueva imagen de fondo
                              fit: BoxFit.cover,
                            ),
                          ),
                          // El QR y la dirección
                          Center(
                            child: _QrCodeView(walletAddress: walletAddress),
                          ),
                        ],
                      )
                    // --- VISTA FRONTAL (BALANCE) ---
                    : Stack(
                        // Key única
                        key: const ValueKey(false),
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/wallet.png', // <-- Tu imagen de fondo frontal
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Contenido de la cara frontal
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Stack(
                              children: [
                                const Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Icon(Icons.lock_rounded,
                                      color: AppColors.primary, size: 24),
                                ),
                                const Positioned(
                                  top: 0,
                                  right: 0,
                                  child: _WalletSettingsMenu(),
                                ),
                                Center(
                                  child:
                                      _BalanceView(balance: balanceFormatted),
                                ),
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Text('CUDI',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // 2. Botones de Acción (Buy, Send, Receive)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WalletActionButton(
                icon: Icons.add,
                label: 'Buy',
                isDisabled: true, // Deshabilitado para el Hackathon
                onTap: () {
                  // Lógica de On-Ramp (Futuro)
                },
              ),
              _WalletActionButton(
                icon: Icons.arrow_upward_rounded,
                label: 'Send',
                onTap: () => context.pushNamed(AppRoutes.sendSafeName),
              ),
              _WalletActionButton(
                icon: Icons.arrow_downward_rounded,
                label: 'Receive',
                onTap:
                    _toggleView, // ¡Este botón ahora también "voltea" la tarjeta!
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Vista de Balance
class _BalanceView extends StatelessWidget {
  final String balance;

  const _BalanceView({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Text(
        '$balance USDC',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Vista de Código QR
class _QrCodeView extends StatelessWidget {
  final String walletAddress;

  const _QrCodeView({required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    // SOLUCIÓN: Se eliminó el 'Container' blanco para que el QR
    // se dibuje directamente sobre el fondo de la imagen 'back_wallet.png'.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrar el QR
        children: [
          QrImageView(
            data: walletAddress,
            version: QrVersions.auto,
            size: 130.0, // Un poco más grande
            // El fondo del QR es transparente
            backgroundColor: Colors.transparent,
            // El color del QR es blanco para contrastar con el fondo oscuro
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
