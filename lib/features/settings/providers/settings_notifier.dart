import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safepay/core/providers/global_providers.dart';
import 'package:safepay/data/models/transaction_model.dart';
import 'package:safepay/data/models/user_model.dart';
import 'package:safepay/features/activity/providers/activity_notifier.dart';

// Modelo para una notificación (Pág 25)
class NotificationModel {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final double? amount;

  const NotificationModel({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.generic,
    this.amount,
  });

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      title: title,
      subtitle: subtitle,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
      amount: amount,
    );
  }
}

enum NotificationType {
  paymentReceived,
  subscriptionActive,
  paymentFailure,
  pendingRequest,
  paymentConfirmed,
  generic
}

// Modelo de estado que combina ajustes y notificaciones
class SettingsState {
  final List<NotificationModel> notifications;
  final bool isGaslessEnabled;
  final bool isNotificationsEnabled;

  const SettingsState({
    this.notifications = const [],
    this.isGaslessEnabled = true,
    this.isNotificationsEnabled = true,
  });

  SettingsState copyWith({
    List<NotificationModel>? notifications,
    bool? isGaslessEnabled,
    bool? isNotificationsEnabled,
  }) {
    return SettingsState(
      notifications: notifications ?? this.notifications,
      isGaslessEnabled: isGaslessEnabled ?? this.isGaslessEnabled,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final UserModel _currentUser;
  final StateController<bool> _biometricsController;

  SettingsNotifier(this._currentUser, this._biometricsController)
      : super(const SettingsState()) {
    _loadInitialNotifications();
  }

  // --- LÓGICA DE NOTIFICACIONES ---

  void _loadInitialNotifications() {
    final now = DateTime.now();
    state = state.copyWith(
      notifications: [
        NotificationModel(
          title: 'Payment Received from @amigodigital',
          subtitle: 'now',
          timestamp: now,
          isRead: false,
          type: NotificationType.paymentReceived,
          amount: 30.00,
        ),
        NotificationModel(
          title: 'Active Subscription: @thedigitallig...',
          subtitle: '8:15 AM',
          timestamp: now.subtract(const Duration(hours: 1)),
          isRead: false,
          type: NotificationType.subscriptionActive,
        ),
        NotificationModel(
          title: 'ATTENTION! Recurring Payment Failure',
          subtitle: 'Yesterday 10:15 PM',
          timestamp: now.subtract(const Duration(days: 1)),
          isRead: true, // Visto (color gris en el diseño)
          type: NotificationType.paymentFailure,
        ),
        NotificationModel(
          title: 'Payment Confirmed to @professorvijay',
          subtitle: '28 Oct 6:40 AM',
          timestamp: now.subtract(const Duration(days: 2)),
          isRead: true,
          type: NotificationType.paymentConfirmed,
          amount: -20.00,
        ),
      ],
    );
  }

  void markNotificationAsRead(NotificationModel notification) {
    final updatedNotifications = state.notifications.map((n) {
      return n == notification ? n.copyWith(isRead: true) : n;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  // --- LÓGICA DE AJUSTES ---

  void toggleGasless(bool isEnabled) {
    state = state.copyWith(isGaslessEnabled: isEnabled);
  }

  void toggleBiometrics(bool isEnabled) {
    _biometricsController.state = isEnabled; // Actualiza el provider global
  }

  void toggleNotifications(bool isEnabled) {
    state = state.copyWith(isNotificationsEnabled: isEnabled);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  // Obtenemos el usuario simulado del ActivityNotifier y el controlador de biometría
  final currentUser =
      ref.watch(activityNotifierProvider.select((state) => state.user!));
  final biometricsController = ref.watch(hasBiometricsProvider.notifier);

  return SettingsNotifier(currentUser, biometricsController);
});

// Proveedor para notificaciones no leídas (Pág 25)
final unreadNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  return ref
      .watch(settingsNotifierProvider)
      .notifications
      .where((n) => !n.isRead)
      .toList();
});
