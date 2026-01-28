import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safepay/data/models/user_model.dart';
import 'package:safepay/data/models/transaction_model.dart';
import 'package:safepay/data/services/transaction_repo.dart';
import 'package:safepay/core/constants/app_constants.dart';
import 'package:safepay/utils/currency_formatter.dart';
import 'dart:math';

// Modelo de estado para la Actividad (Balance y Transacciones)
class ActivityState {
  final UserModel? user;
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? errorMessage;
  final double monthlyYieldEstimate;

  const ActivityState({
    this.user,
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.monthlyYieldEstimate = 0.0,
  });

  ActivityState copyWith({
    UserModel? user,
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? errorMessage,
    double? monthlyYieldEstimate,
  }) {
    return ActivityState(
      user: user ?? this.user,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      monthlyYieldEstimate: monthlyYieldEstimate ?? this.monthlyYieldEstimate,
    );
  }
}

class ActivityNotifier extends StateNotifier<ActivityState> {
  final TransactionRepository _transactionRepository;

  ActivityNotifier(this._transactionRepository) : super(const ActivityState()) {
    fetchActivity();
  }

  // --- LÓGICA DE SOSTENIBILIDAD (Modelo Progresivo) ---

  // Devuelve el porcentaje de Yield que el usuario DEBE recibir
  int _getUserYieldShare(double balance) {
    if (balance >= AppConstants.minFloatForLevel3) {
      // Float Alto (ej. $800+): Usuario recibe 80% (CUDI 20%)
      return 80;
    } else if (balance >= AppConstants.minFloatForLevel2) {
      // Float Medio (ej. $500 - $799): Usuario recibe 60% (CUDI 40%)
      return 60;
    } else {
      // Float Bajo (ej. $200 - $499): Usuario recibe 25% (CUDI 75%)
      return 25;
    }
  }

  // Estima el rendimiento mensual que el usuario recibirá (para mostrar en el Home)
  double _calculateUserMonthlyYield(double balance) {
    const annualYield = 5.0 / 100; // 5.0% APY
    final monthlyTotalYield = balance * annualYield / 12;

    final userSharePercent = _getUserYieldShare(balance);
    return monthlyTotalYield * (userSharePercent / 100);
  }

  // --- LÓGICA DE CARGA DE DATOS ---

  Future<void> fetchActivity() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Cargar perfil real del usuario
      // TODO: Obtener el ID del AuthProvider
      final userProfile =
          await _transactionRepository.fetchUserProfile('user-id-123');

      // 2. Cargar transacciones reales
      final transactions =
          await _transactionRepository.fetchTransactionHistory(userProfile.id);

      // 3. Calcular la estimación del Yield
      final yieldEstimate =
          _calculateUserMonthlyYield(userProfile.currentBalance);
      final userShare = _getUserYieldShare(userProfile.currentBalance);

      final finalUser = userProfile.copyWith(yieldSharePercent: userShare);

      state = state.copyWith(
        user: finalUser,
        transactions: transactions,
        monthlyYieldEstimate: yieldEstimate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar los datos: ${e.toString()}',
      );
    }
  }

  // Simulación: Actualizar balance después de una transacción exitosa
  void updateBalance(double amountChange) {
    if (state.user == null) return;

    final newBalance = max(0.0, state.user!.currentBalance + amountChange);
    final newUser = state.user!.copyWith(
      currentBalance: newBalance,
      yieldSharePercent: _getUserYieldShare(newBalance),
    );

    final yieldEstimate = _calculateUserMonthlyYield(newBalance);

    state = state.copyWith(
      user: newUser,
      monthlyYieldEstimate: yieldEstimate,
    );
  }
}

final activityNotifierProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  return ActivityNotifier(ref.watch(transactionRepositoryProvider));
});

// Proveedor para el Balance Formateado
final currentBalanceFormattedProvider = Provider<String>((ref) {
  final balance = ref.watch(activityNotifierProvider
      .select((state) => state.user?.currentBalance ?? 0.0));
  return CurrencyFormatter.formatYield(balance);
});

// Proveedor para las transacciones recientes (máx. 4 para el Home)
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions =
      ref.watch(activityNotifierProvider.select((state) => state.transactions));
  // Mostramos las últimas 4 o menos para el Home (Página 16)
  return transactions.take(4).toList();
});
