import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safepay/core/constants/app_constants.dart';
import 'package:safepay/core/error/exceptions.dart';

/// Cliente HTTP base para comunicar Flutter → Cloudflare Worker → Render.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// 🔍 Detección de pagos (AI)
  Future<Map<String, dynamic>> detectPayment(String message) async {
    try {
      final response = await _dio.post(
        AppConstants.bulutDetectPaymentEndpoint,
        data: {'message': message},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Network error', e.response?.statusCode);
    } catch (e) {
      throw UnknownException('Unknown error while detecting payment.');
    }
  }

  /// 🪪 Registro de alias y wallet del usuario
  Future<bool> registerUserAlias(String alias, String walletAddress) async {
    try {
      final response = await _dio.post(
        '/user/register',
        data: {
          'alias': alias,
          'walletAddress': walletAddress,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw ApiException('Failed to register alias.', response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Network error', e.response?.statusCode);
    } catch (e) {
      throw UnknownException('Unknown error while registering alias.');
    }
  }

  /// 👤 Obtener perfil del usuario (Balance, Wallet Address, etc.)
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Network error', e.response?.statusCode);
    } catch (e) {
      throw UnknownException('Unknown error fetching user profile.');
    }
  }

  /// 📜 Obtener historial de transacciones
  Future<List<dynamic>> fetchTransactions(String userId) async {
    try {
      final response = await _dio.get('/user/$userId/transactions');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Network error', e.response?.statusCode);
    } catch (e) {
      throw UnknownException('Unknown error fetching transactions.');
    }
  }
}

/// Provider global para inyectar el ApiClient donde se necesite.
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseApiUrl, // 🔗 Worker URL (Cloudflare)
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // ✅ CORS-friendly + logging opcional
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return ApiClient(dio);
});
