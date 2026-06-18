import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}

class AuthSession {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _perfilKey = 'auth_perfil';
  static const String _usuarioIdKey = 'auth_usuario_id';
  static const String _nomeKey = 'auth_nome';
  static const String _cpfKey = 'auth_cpf';

  static String? token;
  static String? perfil;
  static int? usuarioId;
  static String? nome;
  static String? cpf;

  static bool get autenticado => token != null && token!.isNotEmpty;

  static Future<void> carregar() async {
    token = await _storage.read(key: _tokenKey);
    perfil = await _storage.read(key: _perfilKey);
    nome = await _storage.read(key: _nomeKey);
    cpf = await _storage.read(key: _cpfKey);

    final usuarioIdTexto = await _storage.read(key: _usuarioIdKey);
    usuarioId = int.tryParse(usuarioIdTexto ?? '');
  }

  static Future<void> salvar(Map<String, dynamic> json) async {
    token = json['token']?.toString();
    perfil = json['perfil']?.toString();
    usuarioId = _toInt(json['usuarioId']);
    nome = json['nome']?.toString();
    cpf = json['cpf']?.toString();

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _perfilKey, value: perfil);
    await _storage.write(key: _usuarioIdKey, value: usuarioId?.toString());
    await _storage.write(key: _nomeKey, value: nome);
    await _storage.write(key: _cpfKey, value: cpf);
  }

  static Future<void> limpar() async {
    token = null;
    perfil = null;
    usuarioId = null;
    nome = null;
    cpf = null;

    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _perfilKey);
    await _storage.delete(key: _usuarioIdKey);
    await _storage.delete(key: _nomeKey);
    await _storage.delete(key: _cpfKey);
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final List<String> details;

  const ApiException(this.message, {this.statusCode, this.details = const []});

  factory ApiException.fromResponse(
    http.Response response, {
    String? fallbackMessage,
  }) {
    final body = response.body.trim();

    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);

        if (decoded is Map<String, dynamic>) {
          final message = decoded['message']?.toString().trim();
          final error = decoded['error']?.toString().trim();
          final parsedDetails = _parseDetails(decoded['details']);

          if (message != null && message.isNotEmpty) {
            return ApiException(
              message,
              statusCode: response.statusCode,
              details: parsedDetails,
            );
          }

          if (error != null && error.isNotEmpty) {
            return ApiException(
              error,
              statusCode: response.statusCode,
              details: parsedDetails,
            );
          }
        }

        if (decoded is String && decoded.trim().isNotEmpty) {
          return ApiException(decoded.trim(), statusCode: response.statusCode);
        }
      } catch (_) {
        // Se o corpo da resposta não for JSON válido, usa fallback abaixo.
      }
    }

    return ApiException(
      fallbackMessage ?? _defaultMessageForStatus(response.statusCode),
      statusCode: response.statusCode,
    );
  }

  static List<String> _parseDetails(dynamic details) {
    if (details is! List) return [];

    return details
        .where((item) => item != null)
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String _defaultMessageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Dados inválidos. Verifique as informações enviadas.';
      case 401:
        return 'Sessão inválida ou expirada. Faça login novamente.';
      case 403:
        return 'Você não tem permissão para realizar esta ação.';
      case 404:
        return 'Registro não encontrado.';
      case 409:
        return 'Não foi possível concluir a operação por conflito nos dados.';
      case 500:
        return 'Erro interno no servidor.';
      default:
        return 'Erro inesperado na comunicação com o servidor.';
    }
  }

  @override
  String toString() {
    if (details.isEmpty) return message;

    return '$message\n${details.map((detail) => '• $detail').join('\n')}';
  }
}

class ApiClient {
  static Uri uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  static Map<String, String> headers({bool json = false}) {
    final headers = <String, String>{'Accept': 'application/json'};

    if (json) {
      headers['Content-Type'] = 'application/json';
    }

    final token = AuthSession.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<http.Response> get(String path) {
    return _send(() => http.get(uri(path), headers: headers()));
  }

  static Future<http.Response> post(String path, Object? body) {
    return _send(
      () => http.post(uri(path), headers: headers(json: true), body: body),
    );
  }

  static Future<http.Response> put(String path, Object? body) {
    return _send(
      () => http.put(uri(path), headers: headers(json: true), body: body),
    );
  }

  static Future<http.Response> delete(String path) {
    return _send(() => http.delete(uri(path), headers: headers()));
  }

  static Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } catch (_) {
      throw const ApiException(
        'Não foi possível conectar ao servidor. Tente novamente mais tarde',
      );
    }
  }

  static void ensureSuccess(
    http.Response response, {
    List<int> acceptedStatusCodes = const [200],
    String? fallbackMessage,
  }) {
    if (!acceptedStatusCodes.contains(response.statusCode)) {
      throw ApiException.fromResponse(
        response,
        fallbackMessage: fallbackMessage,
      );
    }
  }
}
