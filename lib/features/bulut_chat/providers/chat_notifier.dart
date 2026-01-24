import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safepay/data/models/payment_json_model.dart';
// SOLUCIÓN 2: Importa el MODELO, no la UI
import 'package:safepay/features/bulut_chat/models/chat_message_model.dart';
import 'package:safepay/data/services/api_client.dart';
import 'package:safepay/core/error/exceptions.dart';
// SOLUCIÓN 1: Importa el CurrencyFormatter que te faltaba
import 'package:safepay/utils/currency_formatter.dart';

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ApiClient _apiClient;

  ChatNotifier(this._apiClient)
      : super([
          // Mensaje inicial de bienvenida de Bulut (Página 28)
          const ChatMessage(
            // <-- Se puede usar 'const' ahora
            text:
                "Hi @saitama. I'm Bulut. How can I help you manage your payments today?",
            isUser: false,
          ),
        ]);

  // Simula la llamada a la IA para detectar la intención de pago
  Future<PaymentJsonModel> _detectPaymentIntent(String message) async {
    // ... (tu lógica de detección está bien) ...
    if (message.toLowerCase().contains('pay') ||
        message.toLowerCase().contains('pagar')) {
      await Future.delayed(const Duration(seconds: 1));
      return PaymentJsonModel(
        paymentDetected: true,
        recipientAlias: '@freejournalist',
        amount: 15.00,
        memo: message,
      );
    }
    return PaymentJsonModel(paymentDetected: false);
  }

  // Enviar mensaje del usuario
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // 1. Añadir el mensaje del usuario a la lista
    final userMessage = ChatMessage(text: message, isUser: true);
    state = [...state, userMessage];

    try {
      // 2. Detección de intención de pago
      final paymentData = await _detectPaymentIntent(message);

      if (paymentData.paymentDetected) {
        // 3. Si se detecta pago...
        final bulutConfirmationMessage = ChatMessage(
          // ¡AQUÍ ESTABA EL ERROR! Ahora 'CurrencyFormatter' sí existe.
          text:
              'Pay ${CurrencyFormatter.formatYield(paymentData.amount!)} to ${paymentData.recipientAlias}',
          isUser: false,
          paymentData: paymentData,
        );
        state = [...state, bulutConfirmationMessage];
      } else {
        // 4. Respuesta estándar de la IA (Simulación)
        final bulutResponse = const ChatMessage(
            // <-- Se puede usar 'const'
            text: 'Entendido. ¿Qué más puedo hacer por ti?',
            isUser: false);
        state = [...state, bulutResponse];
      }
    } on ApiException catch (e) {
      final errorResponse =
          ChatMessage(text: 'Error de la API: ${e.message}', isUser: false);
      state = [...state, errorResponse];
    } catch (e) {
      final errorResponse = ChatMessage(
          text: 'Error desconocido: ${e.toString()}', isUser: false);
      state = [...state, errorResponse];
    }
  }

  // Confirmar la transacción (al presionar 'Send' en la tarjeta)
  void confirmTransaction(ChatMessage confirmationMessage, String txId) {
    // 1. Marcar el mensaje de Bulut como confirmado
    final updatedMessage = confirmationMessage.copyWith(
      isConfirmed: true,
      transactionId: txId,
    );

    state = [
      for (final msg in state)
        if (msg == confirmationMessage) updatedMessage else msg
    ];
  }

  // Cancelar la transacción (al presionar 'No' en la tarjeta)
  void cancelTransaction(ChatMessage confirmationMessage) {
    // 1. Eliminar la tarjeta de confirmación
    state = state.where((msg) => msg != confirmationMessage).toList();

    // 2. Añadir una respuesta de Bulut
    final cancellationResponse = const ChatMessage(
        // <-- Se puede usar 'const'
        text: 'Transacción cancelada. Dime si quieres realizar otra acción.',
        isUser: false);
    state = [...state, cancellationResponse];
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  // Inyectamos la dependencia de ApiClient
  return ChatNotifier(ref.watch(apiClientProvider));
});

// Proveedor para el texto inicial (se simula el alias @saitama)
final initialBulutGreetingProvider = Provider<String>((ref) {
  // Cuando el usuario se registra, podríamos obtener el alias real de UserModel
  return "Hi @saitama. I'm Bulut. How can I help you manage your payments today?";
});

// SOLUCIÓN 3: Se elimina la extensión 'copyWith' de aquí.
// Ya está DENTRO de la clase ChatMessage, en su propio archivo.
