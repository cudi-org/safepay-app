import 'package:intl/intl.dart';

// Utility para formatear números como moneda (USDC/USD).

class CurrencyFormatter {
  // Formato para USDC, dos decimales y el símbolo '$'.
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_US', // Usamos locale US para el símbolo $ y el separador.
    symbol: '\$', // Usamos el símbolo USD para la interfaz
    decimalDigits: 2,
  );

  // Método estático para formatear valores double.
  static String format(double amount) {
    return _formatter.format(amount);
  }

  // Método estático para formatear valores de rendimiento sin el símbolo.
  // Se usa para mostrar balance o montos puros (ej. "100.00 USDC" o "+1.66").
  static String formatYield(double amount) {
    // Aseguramos que sea un número positivo y lo formateamos sin símbolo.
    return amount.abs().toStringAsFixed(2);
  }
}
