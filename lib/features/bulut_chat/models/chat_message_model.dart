import 'package:safepay/data/models/payment_json_model.dart';

// El modelo de datos, ahora en su propio archivo.
class ChatMessage {
  final String text;
  final bool isUser; // 'isUser' es más claro que 'isSentByMe' para el Notifier
  final bool isConfirmed;
  final PaymentJsonModel? paymentData;
  final String? transactionId;

  const ChatMessage({
    // Añadido 'const'
    required this.text,
    required this.isUser,
    this.paymentData,
    this.isConfirmed = false,
    this.transactionId,
  });

  // El método 'copyWith' va DENTRO de la clase, no como una extensión
  ChatMessage copyWith({
    String? text,
    bool? isUser,
    bool? isConfirmed,
    PaymentJsonModel? paymentData,
    String? transactionId,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      paymentData: paymentData ?? this.paymentData,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  // Buenas prácticas: Añadir '==' y 'hashCode' para que Riverpod sepa
  // si el objeto ha cambiado realmente.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isUser == other.isUser &&
          isConfirmed == other.isConfirmed &&
          paymentData == other.paymentData &&
          transactionId == other.transactionId;

  @override
  int get hashCode =>
      text.hashCode ^
      isUser.hashCode ^
      isConfirmed.hashCode ^
      paymentData.hashCode ^
      transactionId.hashCode;
}
