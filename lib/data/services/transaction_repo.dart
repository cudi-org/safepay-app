// lib/data/services/transaction_repo.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safepay/data/models/transaction_model.dart';
import 'package:safepay/data/models/user_model.dart';
import 'package:safepay/data/services/api_client.dart';

// 1. Repositorio Real
class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository(this._apiClient);

  /// Obtiene el usuario real desde el Backend
  Future<UserModel> fetchUserProfile(String userId) async {
    final data = await _apiClient.fetchUserProfile(userId);
    // Asumimos que el JSON coincide con el modelo
    return UserModel(
      id: userId,
      alias: data['alias'] ?? '@unknown',
      walletAddress: data['walletAddress'] ?? '',
      currentBalance: (data['balance'] ?? 0.0).toDouble(),
      yieldSharePercent: 0, // Se calcula en el Notifier o viene del back
    );
  }

  /// Obtiene las transacciones reales
  Future<List<TransactionModel>> fetchTransactionHistory(String userId) async {
    final List<dynamic> data = await _apiClient.fetchTransactions(userId);

    return data.map((json) {
      // Mapeo simple de JSON a TransactionModel
      return TransactionModel(
        id: json['id'] ?? 'freq-0',
        type: _parseTransactionType(json['type']),
        amount: (json['amount'] ?? 0.0).toDouble(),
        counterpartyAlias: json['counterparty'] ?? 'Unknown',
        timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
        status: json['status'] ?? 'Completed',
      );
    }).toList();
  }

  TransactionType _parseTransactionType(String? type) {
    switch (type) {
      case 'sent': return TransactionType.sent;
      case 'received': return TransactionType.received;
      case 'yieldGain': return TransactionType.yieldGain;
      case 'deposit': return TransactionType.deposit;
      case 'withdrawal': return TransactionType.withdrawal;
      default: return TransactionType.sent;
    }
  }
}

// 2. Provider actualizado con inyección de ApiClient
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransactionRepository(apiClient);
});
