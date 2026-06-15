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

class ApiClient {
  static Uri uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  static Map<String, String> headers({bool json = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

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
