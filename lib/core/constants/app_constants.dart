// Constantes que definen la configuración base de la aplicación.

class AppConstants {
  // SOLUCIÓN 1: Renombrado de 'baseUrl' a 'baseApiUrl' para que coincida con ApiClient
  static const String baseApiUrl = 'https://api.cudisafepay.com/v1';

  // SOLUCIÓN 2: Añadida la constante que faltaba para ApiClient
  static const String bulutDetectPaymentEndpoint = '/ai/detect-payment';

  // --- Tus otras constantes (están perfectas) ---
  static const String circlePublicKey = 'pk_mock_abcdef123456';
  static const String bulutGreeting =
      'Hola, soy Bulut. ¿En qué puedo ayudarte hoy?';

  // Límites para el modelo progresivo (usados en la lógica financiera)
  static const double minFloatForLevel2 = 500.0;
  static const double minFloatForLevel3 = 800.0;
  static const double apyPercentage = 0.05; // 5.0% APY
  static const double operationalCostPerMonth = 0.60; // Costo en USDC
}
