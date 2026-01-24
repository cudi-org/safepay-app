// lib/data/models/user_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  // ID interno del usuario
  final String id;
  // Alias de usuario (e.g., @juanperez)
  final String alias;
  // La dirección de la wallet en la red Arc
  final String walletAddress;
  // Saldo actual (float) del usuario
  final double currentBalance;
  // Porcentaje de yield que le corresponde (para la lógica progresiva)
  final int yieldSharePercent;

  // SOLUCIÓN 1: Añade 'const' al constructor
  const UserModel({
    required this.id,
    required this.alias,
    required this.walletAddress,
    required this.currentBalance,
    required this.yieldSharePercent,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // SOLUCIÓN 2: Añade el método 'copyWith'
  // (json_serializable no lo genera automáticamente)
  UserModel copyWith({
    String? id,
    String? alias,
    String? walletAddress,
    double? currentBalance,
    int? yieldSharePercent,
  }) {
    return UserModel(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      walletAddress: walletAddress ?? this.walletAddress,
      currentBalance: currentBalance ?? this.currentBalance,
      yieldSharePercent: yieldSharePercent ?? this.yieldSharePercent,
    );
  }

  // --- RECOMENDACIÓN DE MEJORES PRÁCTICAS ---
  // Añade esto para que Riverpod (y Dart en general)
  // sepa cuándo dos objetos UserModel son realmente idénticos.
  // Es crucial para optimizar rebuilds.

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          alias == other.alias &&
          walletAddress == other.walletAddress &&
          currentBalance == other.currentBalance &&
          yieldSharePercent == other.yieldSharePercent;

  @override
  int get hashCode =>
      id.hashCode ^
      alias.hashCode ^
      walletAddress.hashCode ^
      currentBalance.hashCode ^
      yieldSharePercent.hashCode;
}
