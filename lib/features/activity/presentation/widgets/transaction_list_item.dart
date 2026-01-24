import 'package:flutter/material.dart';
import 'package:safepay/data/models/transaction_model.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

// --- WIDGETS AUXILIARES ---

// Devuelve el icono y el color según el tipo de transacción (Páginas 13, 16, 15 Infographic)
class _TransactionIcon extends StatelessWidget {
  final TransactionType type;
  final bool isNegative; // Se usa para la dirección del flujo

  const _TransactionIcon({required this.type, required this.isNegative});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case TransactionType.sent:
      case TransactionType.withdrawal:
        icon = Icons.attach_money; // S para Single Payment (Pág 15 Infographic)
        color = AppColors.textPrimary;
        break;
      case TransactionType.deposit:
      case TransactionType.received:
        icon = Icons.add; // + para Income (Pág 15 Infographic)
        color = AppColors.primary;
        break;
      case TransactionType.yieldGain:
        icon = Icons.autorenew; // Suscripción (Pág 15 Infographic)
        color = AppColors.veronica;
        break;
      default:
        icon = Icons.help_outline;
        color = AppColors.disabled;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// --- WIDGET PRINCIPAL ---

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final bool
      isRecent; // Si es para la lista pequeña (Home) o la lista completa (Activity)

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.isRecent = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar si es un flujo de salida (rojo/negro) o de entrada (verde)
    final bool isNegative = transaction.amount.isNegative ||
        transaction.type == TransactionType.sent ||
        transaction.type == TransactionType.withdrawal;
    final Color amountColor =
        isNegative ? AppColors.textPrimary : AppColors.primary;

    // Formateo de la hora/fecha (ej. "Yesterday 10:15 AM" o "3:00 AM")
    String timeOrDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final txDate = DateTime(transaction.timestamp.year,
        transaction.timestamp.month, transaction.timestamp.day);

    if (txDate.isAtSameMomentAs(today)) {
      timeOrDate = DateFormat('h:mm a').format(transaction.timestamp);
    } else if (txDate.isAtSameMomentAs(yesterday)) {
      timeOrDate =
          'Yesterday ${DateFormat('h:mm a').format(transaction.timestamp)}';
    } else {
      timeOrDate = DateFormat('dd MMM h:mm a').format(transaction.timestamp);
    }

    // Usamos el color de fondo para que el elemento sea un poco más visible (Página 16)
    return Container(
      margin: EdgeInsets.only(
          bottom: isRecent ? 12 : 8,
          right: isRecent ? 0 : 16,
          left: isRecent ? 0 : 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Sombra suave si no es la lista reciente (opcional, pero mejora el diseño)
        boxShadow: isRecent
            ? null
            : [
                BoxShadow(
                    color: AppColors.textPrimary.withOpacity(0.05),
                    blurRadius: 4)
              ],
      ),
      child: Row(
        children: [
          // Icono (Página 16)
          _TransactionIcon(type: transaction.type, isNegative: isNegative),
          const SizedBox(width: 16),

          // Alias / Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.counterpartyAlias,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  timeOrDate,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Monto (Página 16)
          Text(
            // El signo '-' o '+' ya está incluido en el amount formateado
            '${isNegative ? '-' : '+'} ${CurrencyFormatter.formatYield(transaction.amount.abs())} USDC',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amountColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
