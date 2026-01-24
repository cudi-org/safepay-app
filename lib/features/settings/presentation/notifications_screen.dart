import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safepay/core/constants/app_colors.dart';
import 'package:safepay/utils/currency_formatter.dart';
import 'package:safepay/features/settings/providers/settings_notifier.dart';

// --- WIDGETS AUXILIARES ---

// Icono de Notificación (Pág 25)
class _NotificationIcon extends StatelessWidget {
  final NotificationType type;

  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.paymentReceived:
        icon = Icons.add;
        color = AppColors.primary;
        break;
      case NotificationType.subscriptionActive:
        icon = Icons.autorenew;
        color = AppColors.textPrimary;
        break;
      case NotificationType.paymentFailure:
        icon = Icons.warning_amber_rounded;
        color = AppColors.danger; // FF6969
        break;
      case NotificationType.pendingRequest:
        icon = Icons.check_box_outline_blank_rounded;
        color = AppColors.veronica;
        break;
      case NotificationType.paymentConfirmed:
        icon = Icons.remove;
        color = AppColors.textPrimary;
        break;
      case NotificationType.generic:
      default:
        icon = Icons.info_outline;
        color = AppColors.textSecondary;
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

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);
    final notifications = state.notifications;

    // Si no hay notificaciones
    if (notifications.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_off_rounded,
                  size: 80, color: AppColors.disabled),
              const SizedBox(height: 16),
              Text(
                'NOTHING TO SEE HERE',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header del Modal (Pág 24)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications',
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

            // Lista de Notificaciones
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  // Determinar el color de fondo (Pág 25)
                  Color backgroundColor;
                  if (notification.type == NotificationType.paymentFailure) {
                    backgroundColor =
                        AppColors.danger.withOpacity(0.1); // Advertencia FF6969
                  } else {
                    backgroundColor = notification.isRead
                        ? Colors.white
                        : AppColors.primary
                            .withOpacity(0.1); // No vistas #00C9A7
                  }

                  // Texto y subtítulo
                  String amountText = '';
                  if (notification.amount != null) {
                    amountText = notification.amount!.isNegative
                        ? CurrencyFormatter.formatYield(
                            notification.amount!.abs())
                        : '+${CurrencyFormatter.formatYield(notification.amount!.abs())}';
                  }

                  return InkWell(
                    onTap: () {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .markNotificationAsRead(notification);
                      // Lógica de navegación al detalle de la notificación
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _NotificationIcon(type: notification.type),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  notification.subtitle,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            amountText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: notification.amount != null &&
                                      notification.amount! > 0
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
