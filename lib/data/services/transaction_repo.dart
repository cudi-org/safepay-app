// lib/data/services/transaction_repo.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safepay/data/models/transaction_model.dart';
import 'package:safepay/data/models/user_model.dart';
import 'package:safepay/data/services/api_client.dart';

// 1. Repositorio Real
class TransactionRepository {
  // final ApiClient _apiClient;

  TransactionRepository(ApiClient apiClient); // : _apiClient = apiClient;

  /// Obtiene el usuario real desde el Backend (MOCKED por ahora)
  Future<UserModel> fetchUserProfile(String userId) async {
    // MOCK DATA
    await Future.delayed(const Duration(milliseconds: 500));
    // final data = await _apiClient.fetchUserProfile(userId);
    return UserModel(
      id: userId,
      alias: '@gabriel_dev',
      walletAddress: '0x1234...abcd',
      currentBalance: 12500.75,
      yieldSharePercent: 0,
    );
  }

  /// Obtiene transacciones simuladas (Mock) hasta que el API esté lista
  Future<List<TransactionModel>> fetchTransactionHistory(String userId) async {
    // MOCK DATA: Retornamos datos falsos para evitar errores de red en desarrollo
    await Future.delayed(const Duration(milliseconds: 800)); // Simula latencia

    return [
      TransactionModel(
        id: 'tx-1',
        type: TransactionType.received,
        amount: 2500.00,
        counterpartyAlias: 'Sarah W.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        status: 'Completed',
      ),
      TransactionModel(
        id: 'tx-2',
        type: TransactionType.sent,
        amount: 120.50,
        counterpartyAlias: 'Coffee Shop',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Completed',
      ),
      TransactionModel(
        id: 'tx-3',
        type: TransactionType.yieldGain,
        amount: 5.42,
        counterpartyAlias: 'Arc Yield',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Completed',
      ),
      TransactionModel(
        id: 'tx-4',
        type: TransactionType.withdrawal,
        amount: 500.00,
        counterpartyAlias: 'Bank Transfer',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Completed',
      ),
    ];
  }

  // --- COMENTADO: IMPLEMENTACIÓN REAL ---
  // Future<List<TransactionModel>> fetchTransactionHistory(String userId) async {
  //   final List<dynamic> data = await _apiClient.fetchTransactions(userId);
  //
  //   return data.map((json) {
  //     return TransactionModel(
  //       id: json['id'] ?? 'freq-0',
  //       type: _parseTransactionType(json['type']),
  //       amount: (json['amount'] ?? 0.0).toDouble(),
  //       counterpartyAlias: json['counterparty'] ?? 'Unknown',
  //       timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
  //       status: json['status'] ?? 'Completed',
  //     );
  //   }).toList();
  // }
}

// 2. Provider actualizado con inyección de ApiClient
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransactionRepository(apiClient);
});
