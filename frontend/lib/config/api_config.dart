import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:8080';

class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
}

class AuthSession {
  static String? token;
  static String? perfil;
  static int? usuarioId;
  static String? nome;
  static String? cpf;

  static bool get autenticado => token != null && token!.isNotEmpty;

  static void salvar(Map<String, dynamic> json) {
    token = json['token']?.toString();
    perfil = json['perfil']?.toString();
    usuarioId = _toInt(json['usuarioId']);
    nome = json['nome']?.toString();
    cpf = json['cpf']?.toString();
  }

  static void limpar() {
    token = null;
    perfil = null;
    usuarioId = null;
    nome = null;
    cpf = null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class ApiClient {
  static Uri uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  static Map<String, String> headers({bool json = false}) {
    final headers = <String, String>{};

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
    return http.get(uri(path), headers: headers());
  }

  static Future<http.Response> post(String path, Object? body) {
    return http.post(uri(path), headers: headers(json: true), body: body);
  }

  static Future<http.Response> put(String path, Object? body) {
    return http.put(uri(path), headers: headers(json: true), body: body);
  }

  static Future<http.Response> delete(String path) {
    return http.delete(uri(path), headers: headers());
  }
}
