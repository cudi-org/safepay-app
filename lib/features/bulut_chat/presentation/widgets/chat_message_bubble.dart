import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Asegúrate de tener este import
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/utils/currency_formatter.dart';
// SOLUCIÓN: Importa el NOTIFIER
import 'package:safepay/features/bulut_chat/providers/chat_notifier.dart';
// SOLUCIÓN: Importa el MODELO
import 'package:safepay/features/bulut_chat/models/chat_message_model.dart';

// SOLUCIÓN: El modelo 'ChatMessage' YA NO VIVE AQUÍ.
// Se ha movido a 'chat_message_model.dart'

// === WIDGETS AUXILIARES ===

// La tarjeta de confirmación que aparece en el chat (Página 28)
class ConfirmTransactionCard extends StatelessWidget {
  // ... (Tu código para este widget está perfecto) ...
  final ChatMessage message;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const ConfirmTransactionCard({
    super.key,
    required this.message,
    required this.onSend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final amount = message.paymentData!.amount!;
    final recipient = message.paymentData!.recipientAlias!;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "I've detected a single payment.",
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('- Recipient: $recipient',
              style: const TextStyle(color: AppColors.textPrimary)),
          Text('- Amount: ${CurrencyFormatter.format(amount)}',
              style: const TextStyle(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          const Text(
            "Do you want to confirm this transaction?",
            style: TextStyle(
                color: AppColors.textPrimary, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botón Send
              ElevatedButton(
                onPressed: onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Send',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              // Botón No
              ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.disabled,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('No',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Tarjeta de Recibo después de la confirmación (Página 29)
class ReceiptConfirmationCard extends StatelessWidget {
  // ... (Tu código para este widget y el 'ReceiptModal' está perfecto) ...
  final ChatMessage message;

  const ReceiptConfirmationCard({super.key, required this.message});

  void _showReceipt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReceiptModal(message: message), // Pasa el mensaje al modal
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = message.paymentData!.amount!;
    final recipient = message.paymentData!.recipientAlias!;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.bulutBubble,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Made! ${CurrencyFormatter.formatYield(amount)} USDC to $recipient has been processed on the Arc blockchain.',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Tx ID: ${message.transactionId ?? '0x...'}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _showReceipt(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accent),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'View receipt',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

// Modal de Recibo (Página 29)
class ReceiptModal extends StatelessWidget {
  // ... (Tu código para este widget está perfecto) ...
  final ChatMessage message;

  const ReceiptModal({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final String amount =
        CurrencyFormatter.format(message.paymentData!.amount!);
    final String recipient = message.paymentData!.recipientAlias!;
    final String txId = message.transactionId ?? '0x...';

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Center(
              child: Text(
                'Payment Receipt',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
            ),
            const Divider(height: 30),
            _ReceiptDetail(
                label: 'Status', value: 'Confirmed', color: AppColors.success),
            _ReceiptDetail(label: 'Date', value: '1/10/2025, 6:21:33 PM'),
            _ReceiptDetail(label: 'Amount', value: amount),
            _ReceiptDetail(label: 'Recipient', value: recipient),
            _ReceiptDetail(label: 'Tx ID', value: txId, isCopyable: true),
            const Spacer(),
            const Text(
              'Receipt generated by CUDI SafePay. The transaction is immutable on the blockchain.',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Downloading receipt...')));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Download'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptDetail extends StatelessWidget {
  // ... (Tu código para este widget está perfecto) ...
  final String label;
  final String value;
  final Color? color;
  final bool isCopyable;

  const _ReceiptDetail({
    required this.label,
    required this.value,
    this.color,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: color ?? AppColors.textPrimary,
                  fontWeight: FontWeight.normal,
                ),
              ),
              if (isCopyable)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.copy,
                      size: 16, color: AppColors.textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// === WIDGET PRINCIPAL: MESSAGE BUBBLE ===

class ChatMessageBubble extends ConsumerWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Alineación basada en si el mensaje es del usuario o de Bulut
    final alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser ? AppColors.primary : AppColors.bulutBubble;
    final textColor = message.isUser ? Colors.white : AppColors.textPrimary;

    // Función de manejo de acciones para la tarjeta
    void handleSend() {
      ref.read(chatNotifierProvider.notifier).confirmTransaction(
            message,
            // Simulación: establecer el ID de transacción
            '0xA1b23...9cE',
          );
    }

    void handleCancel() {
      ref.read(chatNotifierProvider.notifier).cancelTransaction(message);
    }

    // Contenedor principal de la burbuja
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // 1. Burbuja de Texto
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isUser ? 16 : 0),
                  topRight: Radius.circular(message.isUser ? 0 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),

            // 2. Contenido Adicional (Tarjeta de Confirmación o Recibo)
            if (message.paymentData != null)
              message.isConfirmed
                  ? ReceiptConfirmationCard(message: message)
                  : ConfirmTransactionCard(
                      message: message,
                      onSend: handleSend,
                      onCancel: handleCancel,
                    ),
          ],
        ),
      ),
    );
  }
}
