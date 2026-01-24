import 'package:intl/intl.dart';

// Utility para formatear números como moneda (USDC/USD).

class CurrencyFormatter {
  // Formato para USDC, dos decimales y el símbolo '$'.
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_US', // Usamos locale US para el símbolo $ y el separador.
    symbol: 'USDC',
    decimalDigits: 2,
  );

  // Método estático para formatear valores double.
  static String format(double amount) {
    return _formatter.format(amount);
  }

  // Método estático para formatear valores de rendimiento sin el símbolo.
  static String formatYield(double amount) {
    return amount.toStringAsFixed(2);
  }
}
