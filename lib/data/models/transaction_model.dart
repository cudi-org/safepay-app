// lib/data/models/transaction_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

// Enum para el tipo de transacción
enum TransactionType { deposit, withdrawal, sent, received, yieldGain }

@JsonSerializable()
class TransactionModel {
  final String id;
  final TransactionType type;
  // Monto positivo para depósitos/recibidos/yield, negativo para retiros/enviados
  final double amount;
  final String counterpartyAlias; // El otro @alias
  final DateTime timestamp;
  final String status; // Ej: 'Completed', 'Pending', 'Failed'

  // SOLUCIÓN 1: Añadido 'const'
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.counterpartyAlias,
    required this.timestamp,
    required this.status,
  });

  // SOLUCIÓN 2: Corregido 'FábFábrica' por 'factory'
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  // SOLUCIÓN 3: Añadido 'copyWith'
  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? counterpartyAlias,
    DateTime? timestamp,
    String? status,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      counterpartyAlias: counterpartyAlias ?? this.counterpartyAlias,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  // SOLUCIÓN 4: Añadidos '==' y 'hashCode' (Buenas prácticas de Riverpod)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          amount == other.amount &&
          counterpartyAlias == other.counterpartyAlias &&
          timestamp == other.timestamp &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      amount.hashCode ^
      counterpartyAlias.hashCode ^
      timestamp.hashCode ^
      status.hashCode;
}
