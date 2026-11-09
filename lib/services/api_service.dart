import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://18.222.196.208/api';

  /// Performs a health check request to verify server connectivity.
  /// Returns a Map with 'success', 'status', and 'message'.
  static Future<Map<String, dynamic>> checkHealth() async {
    final uri = Uri.parse('$baseUrl/health/');
    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'] ?? 'ok',
          'message': data['message'] ?? 'API disponible',
        };
      } else {
        return {
          'success': false,
          'message': 'Error servidor ${response.statusCode}: ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'No se pudo conectar al servidor ($e)',
      };
    }
  }
}
