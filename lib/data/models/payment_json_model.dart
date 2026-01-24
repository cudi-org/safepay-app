import 'package:json_annotation/json_annotation.dart';

part 'payment_json_model.g.dart';

// Modelo para la respuesta JSON que la IA (Bulut/FastAPI) envía
// al detectar una intención de pago en el chat.
@JsonSerializable()
class PaymentJsonModel {
  // Indicador booleano: ¿Se detectó una intención de pago?
  final bool paymentDetected;
  // Alias del destinatario (e.g., '@creator_name')
  final String? recipientAlias;
  // Monto a enviar
  final double? amount;
  // Mensaje que el usuario quiere adjuntar a la transacción
  final String? memo;

  PaymentJsonModel({
    required this.paymentDetected,
    this.recipientAlias,
    this.amount,
    this.memo,
  });

  factory PaymentJsonModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentJsonModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentJsonModelToJson(this);
}
