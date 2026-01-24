// lib/data/services/transaction_repo.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safepay/data/models/transaction_model.dart';

// 1. LA CLASE QUE FALTABA (TransactionRepository)
class TransactionRepository {
  // Este es el método que tu 'ActivityNotifier' está intentando llamar
  Future<List<TransactionModel>> fetchTransactionHistory(String userId) async {
    // Simula un retraso de red para que parezca real
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulación de datos (Mock)
    // Usamos el constructor 'const' que acabamos de añadir a TransactionModel
    return [
      TransactionModel(
        id: 'tx-003',
        type: TransactionType.yieldGain,
        amount: 2.12,
        counterpartyAlias: '@safepay_yield',
        timestamp: DateTime(2025, 11, 1),
        status: 'Completed',
      ),
      TransactionModel(
        id: 'tx-002',
        type: TransactionType.sent,
        amount: -50.0,
        counterpartyAlias: '@genzo',
        timestamp: DateTime(2025, 10, 28, 14, 30),
        status: 'Completed',
      ),
      TransactionModel(
        id: 'tx-001',
        type: TransactionType.deposit,
        amount: 550.0,
        counterpartyAlias: '@banco_local',
        timestamp: DateTime(2025, 10, 25, 9, 0),
        status: 'Completed',
      ),
      // Añade más transacciones si quieres probar el límite de 4 en el UI
    ];
  }
}

// 2. EL PROVIDER QUE FALTABA (transactionRepositoryProvider)
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  // Simplemente creamos y devolvemos la instancia del repositorio
  return TransactionRepository();
});
