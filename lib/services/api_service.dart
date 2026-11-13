import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? fieldErrors;

  ApiException(this.statusCode, this.message, {this.fieldErrors});

  @override
  String toString() => message;
}

class UserDisabledException implements Exception {
  final String message;
  UserDisabledException([this.message = 'Usuario desactivado. Contacta a un administrador.']);

  @override
  String toString() => message;
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException([this.message = 'No tienes permisos suficientes para realizar esta acción.']);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://77.112.240.202/api',
  );

  /// Helper to get current Firebase ID Token and construct headers
  static Future<Map<String, String>> _getHeaders() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (user != null) {
      final String? idToken = await user.getIdToken();
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }
    }

    return headers;
  }

  /// Global response handler for 401, 403, and 400 errors
  static Map<String, dynamic> _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        return body;
      }
      return {'data': body};
    }

    if (response.statusCode == 401) {
      final String detail = (body is Map && body.containsKey('detail'))
          ? body['detail'].toString()
          : 'Usuario desactivado o no autorizado.';
      if (detail.toLowerCase().contains('desactivado')) {
        throw UserDisabledException('Usuario desactivado. Contacta a un administrador.');
      }
      throw ApiException(401, detail);
    }

    if (response.statusCode == 403) {
      final String detail = (body is Map && body.containsKey('detail'))
          ? body['detail'].toString()
          : 'Rol insuficiente.';
      throw ForbiddenException(detail);
    }

    if (response.statusCode == 400) {
      if (body is Map<String, dynamic>) {
        final Map<String, dynamic> fieldErrors = {};
        body.forEach((key, value) {
          if (value is List) {
            fieldErrors[key] = value.map((e) => e.toString()).toList();
          } else {
            fieldErrors[key] = [value.toString()];
          }
        });
        final String firstMsg = fieldErrors.values.first?.first ?? 'Error de validación';
        throw ApiException(400, firstMsg, fieldErrors: fieldErrors);
      }
    }

    final String message = (body is Map && body.containsKey('detail'))
        ? body['detail'].toString()
        : 'Error servidor (${response.statusCode}): ${response.reasonPhrase}';
    throw ApiException(response.statusCode, message);
  }

  /// Health check
  static Future<Map<String, dynamic>> checkHealth() async {
    final uri = Uri.parse('$baseUrl/health/');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
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

  /// GET /auth/me/ - Sync & Get Current Backend User
  static Future<BackendUser> getMe() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/auth/me/');
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
    final data = _processResponse(response);
    return BackendUser.fromJson(data);
  }

  /// PATCH /auth/me/ - Update current user profile (nombre_usuario, nombre_completo)
  static Future<BackendUser> updateMe({
    String? nombreUsuario,
    String? nombreCompleto,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/auth/me/');
    final Map<String, dynamic> body = {};
    if (nombreUsuario != null) body['nombre_usuario'] = nombreUsuario;
    if (nombreCompleto != null) body['nombre_completo'] = nombreCompleto;

    final response = await http
        .patch(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));
    final data = _processResponse(response);
    return BackendUser.fromJson(data);
  }

  /// GET /usuarios/?rol=&activo=&q= - Admin List Users
  static Future<List<BackendUser>> getUsers({
    String? rol,
    bool? activo,
    String? q,
  }) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{};
    if (rol != null && rol.isNotEmpty) queryParams['rol'] = rol;
    if (activo != null) queryParams['activo'] = activo.toString();
    if (q != null && q.isNotEmpty) queryParams['q'] = q;

    final uri = Uri.parse('$baseUrl/usuarios/').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

    final dynamic rawData = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (rawData is List) {
        return rawData.map((e) => BackendUser.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    _processResponse(response); // Throws if error
    return [];
  }

  /// GET /usuarios/{id}/ - Admin Get User
  static Future<BackendUser> getUserById(int id) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/usuarios/$id/');
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
    final data = _processResponse(response);
    return BackendUser.fromJson(data);
  }

  /// PATCH /usuarios/{id}/ - Admin Update User (rol, activo)
  static Future<BackendUser> updateUser(
    int id, {
    String? rol,
    bool? activo,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/usuarios/$id/');
    final Map<String, dynamic> body = {};
    if (rol != null) body['rol'] = rol;
    if (activo != null) body['activo'] = activo;

    final response = await http
        .patch(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));
    final data = _processResponse(response);
    return BackendUser.fromJson(data);
  }
}
