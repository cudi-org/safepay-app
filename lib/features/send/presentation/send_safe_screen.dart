import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/core/providers/global_providers.dart'; // Replaces app_routes.dart
import 'package:safepay/features/send/providers/send_notifier.dart';
import 'package:safepay/utils/currency_formatter.dart';

// --- WIDGETS AUXILIARES ---

// Icono de Avatar (simulado)
class _AvatarIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _AvatarIcon({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

// Botón de Teclado Numérico para Monto
class _NumericKeypadButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isDelete;

  const _NumericKeypadButton({
    required this.text,
    this.icon,
    required this.onPressed,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon,
                  size: 24,
                  color: isDelete ? AppColors.danger : AppColors.textPrimary)
              : Text(
                  text,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.normal),
                ),
        ),
      ),
    );
  }
}

// --- WIDGET PRINCIPAL ---

class SendSafeScreen extends ConsumerStatefulWidget {
  const SendSafeScreen({super.key});

  @override
  ConsumerState<SendSafeScreen> createState() => _SendSafeScreenState();
}

class _SendSafeScreenState extends ConsumerState<SendSafeScreen> {
  // El controlador ahora SÍ empieza en '0'
  final _amountController = TextEditingController(text: '0');

  // SOLUCIÓN 1: 'initState' eliminado. Ya no fuerza el "20.00"

  void _handleKeypadInput(String key) {
    String currentText = _amountController.text.replaceAll(',', '');

    if (key == 'delete') {
      if (currentText.isNotEmpty) {
        currentText = currentText.substring(0, currentText.length - 1);
      }
    } else if (key == '.') {
      if (!currentText.contains('.')) {
        currentText += '.';
      }
    } else {
      if (currentText == '0') {
        currentText = key;
      } else {
        currentText += key;
      }
    }

    if (currentText.isEmpty) currentText = '0';

    // Limitar a dos decimales
    if (currentText.contains('.')) {
      final parts = currentText.split('.');
      if (parts.length > 1 && parts[1].length > 2) {
        currentText = '${parts[0]}.${parts[1].substring(0, 2)}';
      }
    }

    final newAmount = double.tryParse(currentText) ?? 0.0;

    // Validación de saldo disponible
    final currentBalance =
        ref.read(sendNotifierProvider).senderWallet?.currentBalance ?? 0.0;
    if (newAmount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto excede el saldo disponible')),
      );
      // Revertimos al monto anterior (antes de pulsar la tecla)
      return;
    }

    // Actualizamos el controlador y el provider
    _amountController.text = currentText;
    ref.read(sendNotifierProvider.notifier).setAmount(newAmount);
  }

  void _selectRecipient(Recipient recipient) {
    ref.read(sendNotifierProvider.notifier).setRecipient(recipient);
    // Simulación: Iniciar el flujo de detalles después de seleccionar un destinatario
    context.pushNamed(AppRoutes.sendDetailsName);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendNotifierProvider);
    final isAmountValid = ref.watch(isAmountValidProvider);
    final availableBalance = ref.watch(availableBalanceProvider);

    // Destinatario simulado para la vista previa (Página 18/19)
    final walletAddress = state.senderWallet?.walletAddress ?? '0x...';

    // Lista de contactos recientes
    final recentContacts =
        ref.read(sendNotifierProvider.notifier).recentContacts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Send a Safe',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),

            // Wallet Card (Página 18)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_queue,
                      color: AppColors.primary, size: 30),
                  const SizedBox(height: 4),
                  const Text('Wallet',
                      style:
                          TextStyle(color: AppColors.disabled, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Sección Recientes (Página 18/19)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  IconButton(
                    icon:
                        const Icon(Icons.search, color: AppColors.textPrimary),
                    onPressed: () {
                      // Simular búsqueda de alias
                    },
                  ),
                ],
              ),
            ),

            // Lista de contactos recientes
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Botón Agregar
                  _RecipientItem(
                    recipient: Recipient(alias: 'Add'),
                    color: AppColors.textPrimary,
                    icon: Icons.add,
                    onTap: () {/* Lógica de Agregar */},
                  ),
                  ...recentContacts
                      .map((contact) => _RecipientItem(
                            recipient: contact,
                            color: AppColors.veronica,
                            icon: contact.alias == '@freejournalist'
                                ? Icons.person
                                : Icons.group,
                            onTap: () => _selectRecipient(contact),
                          ))
                      .toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Monto (Página 18)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: RichText(
                text: TextSpan(
                  // SOLUCIÓN 2: Eliminado el '.padRight(5, '0')'
                  text: _amountController.text,
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  children: const [
                    TextSpan(
                      text: ' USDC',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Your balance: $availableBalance USDC (available)',
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),

            const Spacer(),

            // Teclado Numérico (4x3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.0,
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
                      .map((key) => _NumericKeypadButton(
                            text: key,
                            onPressed: () => _handleKeypadInput(key),
                          )),
                  _NumericKeypadButton(
                    text: '.',
                    onPressed: () => _handleKeypadInput('.'),
                  ),
                  _NumericKeypadButton(
                    text: '0',
                    onPressed: () => _handleKeypadInput('0'),
                  ),
                  _NumericKeypadButton(
                    text: 'delete',
                    icon: Icons.backspace_outlined,
                    isDelete: true,
                    onPressed: () => _handleKeypadInput('delete'),
                  ),
                ],
              ),
            ),

            // Botón Send (Página 18/19)
            Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAmountValid && state.mainRecipient != null
                      ? () => context.pushNamed(AppRoutes.sendDetailsName)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.disabled,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    // El botón ahora se actualiza con el valor del provider
                    'Send ${CurrencyFormatter.formatYield(state.amount)} USDC',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para un elemento de Destinatario Reciente
class _RecipientItem extends StatelessWidget {
  final Recipient recipient;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _RecipientItem({
    required this.recipient,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            _AvatarIcon(color: color, icon: icon),
            const SizedBox(height: 4),
            Text(
              recipient.alias.length > 5
                  ? '${recipient.alias.substring(0, 5)}...'
                  : recipient.alias,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
