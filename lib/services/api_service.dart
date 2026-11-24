import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      try {
        final String? idToken = await user.getIdToken(true);
        if (idToken != null && idToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $idToken';
          debugPrint('==================================================');
          debugPrint('USUARIO FIREBASE: ${user.email ?? user.uid}');
          debugPrint('FIREBASE ID TOKEN ENVIADO AL SERVIDOR PRODUCCIÓN:');
          debugPrint(idToken);
          debugPrint('==================================================');
          return headers;
        }
      } catch (e) {
        debugPrint('Error obteniendo token de Firebase: $e');
      }
    }

    debugPrint('==================================================');
    debugPrint('SIN SESIÓN AUTENTICADA EN FIREBASE.');
    debugPrint('==================================================');
    return headers;
  }

  /// Global response handler for 401, 403, and 400 errors
  static Map<String, dynamic> _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
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
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
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

  /// GET /modulos/mapa/ - Get Learning Path Map Nodes
  static Future<Map<String, dynamic>> getMapNodes() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/modulos/mapa/');
    debugPrint('Cargando mapa desde: $uri');
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('Respuesta mapa (${response.statusCode}): ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic rawData = jsonDecode(utf8.decode(response.bodyBytes));
        if (rawData is List) {
          final list = List<Map<String, dynamic>>.from(rawData);
          if (list.isEmpty) {
            return {
              'success': false,
              'error': 'La API respondió con una lista vacía de módulos.',
              'data': <Map<String, dynamic>>[],
            };
          }
          return {
            'success': true,
            'data': list,
          };
        }
      }
      return {
        'success': false,
        'error': 'Error servidor (${response.statusCode}): ${response.reasonPhrase}',
        'data': <Map<String, dynamic>>[],
      };
    } catch (e) {
      debugPrint('Error cargando mapa desde $uri: $e');
      return {
        'success': false,
        'error': 'No se pudo conectar al servidor ($uri).\nDetalle: $e',
        'data': <Map<String, dynamic>>[],
      };
    }
  }

  /// GET /modulos/{id}/lecciones/ - Get Module Lessons
  static Future<Map<String, dynamic>> getModuleLessons(int moduloId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/modulos/$moduloId/lecciones/');
    debugPrint('Cargando lecciones del módulo desde: $uri');
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      debugPrint('Respuesta lecciones (${response.statusCode}): ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic rawData = jsonDecode(utf8.decode(response.bodyBytes));
        if (rawData is Map<String, dynamic>) {
          return {
            'success': true,
            'data': rawData,
          };
        }
      }
      return {
        'success': false,
        'error': 'Error servidor (${response.statusCode}): ${response.reasonPhrase}',
      };
    } catch (e) {
      debugPrint('Error cargando lecciones desde $uri: $e');
      return {
        'success': false,
        'error': 'No se pudo conectar al servidor ($uri).\nDetalle: $e',
      };
    }
  }

  /// GET /diccionario/ - Get Dictionary Words
  static Future<List<Map<String, dynamic>>> getDictionaryWords() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/diccionario/');
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic rawData = jsonDecode(utf8.decode(response.bodyBytes));
        if (rawData is List) {
          return List<Map<String, dynamic>>.from(rawData);
        }
      }
    } catch (e) {
      debugPrint('Error cargando diccionario: $e');
    }
    return [];
  }

  /// GET /acervos/ - Get Archive Collection Items
  static Future<List<Map<String, dynamic>>> getArchiveItems() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/acervos/');
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic rawData = jsonDecode(utf8.decode(response.bodyBytes));
        if (rawData is List) {
          return List<Map<String, dynamic>>.from(rawData);
        }
      }
    } catch (e) {
      debugPrint('Error cargando acervos: $e');
    }
    return [];
  }

  /// GET /hablantes/ - Get Speakers List
  static Future<List<Map<String, dynamic>>> getSpeakers() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/hablantes/');
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic rawData = jsonDecode(utf8.decode(response.bodyBytes));
        if (rawData is List) {
          return List<Map<String, dynamic>>.from(rawData);
        }
      }
    } catch (e) {
      debugPrint('Error cargando hablantes: $e');
    }
    return [];
  }

  /// POST /modulos/{id}/completar/ - Save module progress and unlock next module
  static Future<Map<String, dynamic>> completeModule({
    required int moduloId,
    required double porcentajeAcierto,
    required bool aprobado,
    int? siguienteModuloId,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/modulos/$moduloId/completar/');
    final Map<String, dynamic> payload = {
      'modulo_id': moduloId,
      'porcentaje_acierto': porcentajeAcierto,
      'aprobado': aprobado,
      'siguiente_modulo_id': siguienteModuloId,
    };
    final body = jsonEncode(payload);

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'data': data,
        };
      }
      return {
        'success': false,
        'error': 'Error al guardar progreso (${response.statusCode})',
      };
    } catch (e) {
      debugPrint('Error guardando progreso del módulo: $e');
      return {
        'success': false,
        'error': 'No se pudo conectar al servidor ($e)',
      };
    }
  }

  /// POST/PATCH /progresos-modulo/ - Create or update module progress
  static Future<Map<String, dynamic>> startModuleProgress({
    required int usuarioId,
    required int moduloId,
    String estado = 'en_curso',
   // int intento = 1,
  }) async {
    final headers = await _getHeaders();
    final collectionUri = Uri.parse('$baseUrl/progresos-modulo/').replace(
      queryParameters: {
        'usuario': usuarioId.toString(),
        'modulo': moduloId.toString(),
      },
    );
    final Map<String, dynamic> payload = {
      'usuario': usuarioId,
      'modulo': moduloId,
      'estado': estado,
      //'intento': intento,
    };

    try {
      // 1. Buscar si ya existe el progreso del usuario en ese módulo.
      final searchResponse = await http
          .get(collectionUri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (searchResponse.statusCode >= 200 && searchResponse.statusCode < 300) {
        final dynamic rawData =
            jsonDecode(utf8.decode(searchResponse.bodyBytes));

        List<dynamic> records = [];
        if (rawData is List) {
          records = rawData;
        } else if (rawData is Map<String, dynamic>) {
          if (rawData['results'] is List) {
            records = rawData['results'] as List<dynamic>;
          } else if (rawData['data'] is List) {
            records = rawData['data'] as List<dynamic>;
          }
        }

        // 2. Si existe, actualizar mediante PATCH.
        if (records.isNotEmpty && records.first is Map) {
          final Map<String, dynamic> existing =
              Map<String, dynamic>.from(records.first as Map);
          final int? progressId = existing['id'] is int
              ? existing['id'] as int
              : int.tryParse(existing['id']?.toString() ?? '');

          if (progressId != null) {
            final detailUri = Uri.parse(
              '$baseUrl/progresos-modulo/$progressId/',
            );
            final patchResponse = await http
                .patch(detailUri, headers: headers, body: jsonEncode(payload))
                .timeout(const Duration(seconds: 10));

            if (patchResponse.statusCode >= 200 &&
                patchResponse.statusCode < 300) {
              final dynamic raw =
                  jsonDecode(utf8.decode(patchResponse.bodyBytes));
              return {
                'success': true,
                'operation': 'patch',
                'data': raw is Map<String, dynamic> ? raw : {'data': raw},
              };
            }

            return {
              'success': false,
              'error':
                  'Error al actualizar el progreso (${patchResponse.statusCode})',
            };
          }
        }
      }

      // 3. Si no existe, crear mediante POST.
      final collectionUriPost = Uri.parse('$baseUrl/progresos-modulo/');
      final postResponse = await http
          .post(collectionUriPost, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 10));

      if (postResponse.statusCode >= 200 && postResponse.statusCode < 300) {
        final dynamic raw = jsonDecode(utf8.decode(postResponse.bodyBytes));
        return {
          'success': true,
          'operation': 'post',
          'data': raw is Map<String, dynamic> ? raw : {'data': raw},
        };
      }

      final dynamic body = jsonDecode(utf8.decode(postResponse.bodyBytes));
      final String error = body is Map<String, dynamic> && body['detail'] is String
          ? body['detail']
          : 'Error al registrar el progreso (${postResponse.statusCode})';
      return {'success': false, 'error': error};
    } catch (e) {
      debugPrint('Error registrando progreso del módulo: $e');
      return {
        'success': false,
        'error': 'No se pudo conectar al servidor ($e)',
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

    final dynamic rawData = jsonDecode(utf8.decode(response.bodyBytes));
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
