// Definición de las excepciones personalizadas para la gestión de errores.

// Excepción base para todos los errores de la aplicación
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

// Errores específicos de la API (ej. 404, 500)
class ApiException extends AppException {
  // SOLUCIÓN 1: Cambiado a 'int?' (nulable)
  final int? statusCode;
  // SOLUCIÓN 2: [this.statusCode] lo hace opcional y acepta 'null'
  ApiException(String message, [this.statusCode]) : super(message);
}

// Errores relacionados con la billetera o el PIN
class WalletException extends AppException {
  WalletException(String message) : super(message);
}

// Error si la IA no detecta una intención de pago válida
class PaymentDetectionException extends AppException {
  PaymentDetectionException(String message) : super(message);
}

// SOLUCIÓN 3: Añadida la clase 'UnknownException' que 'api_client.dart' necesita
class UnknownException extends AppException {
  UnknownException(String message) : super(message);
}
