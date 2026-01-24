import 'package:flutter_riverpod/flutter_riverpod.dart'; // Para el alias
import 'package:safepay/utils/currency_formatter.dart'; // Para formatear

// =====================================================================
// 1. CLASES Y ENUMS DE MODELO
// =====================================================================

// Clase que te faltaba: 'Recipient'
class Recipient {
  final String alias;
  final String? walletAddress;
  // SOLUCIÓN 1: Añadir 'currentBalance'
  final double currentBalance;

  const Recipient({
    required this.alias,
    this.walletAddress,
    this.currentBalance = 0.0, // Darle un valor por defecto
  });

  // SOLUCIÓN 2: Añadir 'currentBalance' al copyWith
  Recipient copyWith({
    String? alias,
    String? walletAddress,
    double? currentBalance,
  }) {
    return Recipient(
      alias: alias ?? this.alias,
      walletAddress: walletAddress ?? this.walletAddress,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  // SOLUCIÓN 3: Añadir 'currentBalance' a la comparación
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipient &&
          runtimeType == other.runtimeType &&
          alias == other.alias &&
          currentBalance == other.currentBalance; // Añadido

  @override
  int get hashCode => alias.hashCode ^ currentBalance.hashCode; // Añadido
}

// Enums que tu UI necesita
enum PaymentType { single, recurrent, divided }

enum RecurrenceFrequency { daily, weekly, monthly }

// =====================================================================
// 2. EL ESTADO (STATE)
// =====================================================================
class SendState {
  // --- Pantalla 1: SendSafeScreen ---
  final Recipient? senderWallet;
  final double amount;
  final Recipient? mainRecipient; // El destinatario principal

  // --- Pantalla 2: SendSafeDetailsScreen ---
  final String concept;
  final PaymentType type;

  // Opciones de 'Recurrent'
  final RecurrenceFrequency frequency;
  final bool isUntilCancelled;
  final DateTime? startDate;

  // Opciones de 'Divided'
  final List<Recipient> safers; // Lista de participantes en el split
  final bool isSplitEqual;
  final Map<String, double> customSplit;

  // --- Estado General ---
  final bool isLoading;
  final String? errorMessage;

  // Constructor con valores por defecto
  const SendState({
    this.senderWallet,
    this.amount = 0.0,
    this.mainRecipient,
    this.concept = '',
    this.type = PaymentType.single,
    this.frequency = RecurrenceFrequency.monthly,
    this.isUntilCancelled = true,
    this.startDate,
    this.safers = const [],
    this.isSplitEqual = true,
    this.customSplit = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  // Método copyWith para mantener la inmutabilidad
  SendState copyWith({
    Recipient? senderWallet,
    double? amount,
    Recipient? mainRecipient,
    String? concept,
    PaymentType? type,
    RecurrenceFrequency? frequency,
    bool? isUntilCancelled,
    DateTime? startDate,
    List<Recipient>? safers,
    bool? isSplitEqual,
    Map<String, double>? customSplit,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SendState(
      senderWallet: senderWallet ?? this.senderWallet,
      amount: amount ?? this.amount,
      mainRecipient: mainRecipient ?? this.mainRecipient,
      concept: concept ?? this.concept,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      isUntilCancelled: isUntilCancelled ?? this.isUntilCancelled,
      startDate: startDate ?? this.startDate,
      safers: safers ?? this.safers,
      isSplitEqual: isSplitEqual ?? this.isSplitEqual,
      customSplit: customSplit ?? this.customSplit,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// =====================================================================
// 3. EL NOTIFIER (LÓGICA)
// =====================================================================
class SendNotifier extends StateNotifier<SendState> {
  // Datos simulados
  final List<Recipient> recentContacts = [
    const Recipient(
        alias: '@freejournalist',
        walletAddress: '0x123...abc',
        currentBalance: 150.0),
    const Recipient(
        alias: '@group', walletAddress: '0x456...def', currentBalance: 0.0),
    const Recipient(
        alias: '@saitama', walletAddress: '0x789...ghi', currentBalance: 500.0),
  ];

  // Simulación de balance
  final double _mockBalance = 500.00;

  // SOLUCIÓN 4: Añadir el balance al _mockSender
  final Recipient _mockSender = const Recipient(
      alias: '@saitama',
      walletAddress: '0x71f9a6d223e14b939f34bf3f3ad91b1188a7dD3E',
      currentBalance: 500.00); // <-- Añadido aquí

  SendNotifier() : super(const SendState()) {
    // Cargar el usuario que envía y su balance al iniciar
    state = state.copyWith(
      senderWallet: _mockSender.copyWith(),
      // Reseteamos el estado por si acaso
      amount: 0.0,
      mainRecipient: null,
    );
  }

  // --- Métodos para SendSafeScreen ---

  void setAmount(double newAmount) {
    state = state.copyWith(amount: newAmount);
  }

  void setRecipient(Recipient recipient) {
    state = state.copyWith(mainRecipient: recipient);
    // Iniciar con un tipo de pago por defecto al seleccionar destinatario
    setPaymentType(PaymentType.single);
  }

  // --- Métodos para SendSafeDetailsScreen ---

  void setConcept(String concept) {
    state = state.copyWith(concept: concept);
  }

  void setPaymentType(PaymentType type) {
    state = state.copyWith(type: type);
  }

  void setFrequency(RecurrenceFrequency frequency) {
    state = state.copyWith(frequency: frequency);
  }

  void setDurationType({required bool isUntilCancelled}) {
    state = state.copyWith(isUntilCancelled: isUntilCancelled);
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void addSafer(Recipient safer) {
    state = state.copyWith(safers: [...state.safers, safer]);
  }

  void removeSafer(Recipient safer) {
    state = state.copyWith(
        safers: state.safers.where((s) => s.alias != safer.alias).toList());
  }

  void toggleSplitType(bool isEqual) {
    state = state.copyWith(isSplitEqual: isEqual);
  }

  void setCustomSplit(String alias, double amount) {
    final newSplit = Map<String, double>.from(state.customSplit);
    newSplit[alias] = amount;
    state = state.copyWith(customSplit: newSplit);
  }

  // Propiedad calculada para el split equitativo
  double get equalSplitAmount {
    if (state.safers.isEmpty) return 0.0;
    // Asegurarse de no dividir por cero
    final numSafers = state.safers.length;
    return (state.amount / numSafers);
  }

  // --- Método para SendAuthScreen ---
  Future<bool> confirmFinalTransaction() async {
    state = state.copyWith(isLoading: true);

    // Aquí iría la lógica real de enviar a la blockchain/API
    // usando state.amount, state.mainRecipient, state.type, etc.

    await Future.delayed(const Duration(seconds: 2));

    final bool success = true; // Simular éxito

    if (success) {
      state = state.copyWith(isLoading: false);
      // Resetear el estado después de un envío exitoso
      state = SendState(senderWallet: state.senderWallet);
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: 'Network Error');
      return false;
    }
  }
}

// =====================================================================
// 4. LOS PROVIDERS (¡AHORA CORREGIDOS!)
// =====================================================================

final sendNotifierProvider =
    StateNotifierProvider<SendNotifier, SendState>((ref) {
  return SendNotifier();
}); // <-- ¡ERROR ARREGLADO! La llave se cierra aquí.

// Provider para el balance disponible (simulado)
// (Ahora está en el nivel superior, fuera del otro provider)
final availableBalanceProvider = Provider<String>((ref) {
  // Ahora podemos leerlo desde el senderWallet en el state
  final balance =
      ref.watch(sendNotifierProvider).senderWallet?.currentBalance ?? 0.0;
  return CurrencyFormatter.format(balance);
});

// Provider que te faltaba: 'isAmountValidProvider'
// (Ahora está en el nivel superior)
final isAmountValidProvider = Provider<bool>((ref) {
  final amount = ref.watch(sendNotifierProvider).amount;
  // Lo leemos del state
  final balance =
      ref.watch(sendNotifierProvider).senderWallet?.currentBalance ?? 0.0;
  return amount > 0 && amount <= balance;
});

// Provider de 'send_safe_details_screen.dart'
// (Ahora está en el nivel superior)
final areDetailsCompleteProvider = Provider<bool>((ref) {
  final state = ref.watch(sendNotifierProvider);

  if (state.concept.isEmpty) return false;

  switch (state.type) {
    case PaymentType.single:
      return true; // Solo necesita concepto
    case PaymentType.recurrent:
      // Necesita lógica de validación de ciclos/fecha
      return true; // Simplificado por ahora
    case PaymentType.divided:
      if (state.safers.isEmpty) return false;
      if (!state.isSplitEqual) {
        // Validar que el split custom sume 100% (o el total)
        final totalSplit = state.customSplit.values.fold(0.0, (a, b) => a + b);
        // Pequeña tolerancia para errores de punto flotante
        return (totalSplit - state.amount).abs() < 0.01;
      }
      return true; // Split equitativo es válido por defecto si hay safers
  }
});
