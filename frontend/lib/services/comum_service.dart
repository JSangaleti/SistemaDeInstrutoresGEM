import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/comum.dart';

class ComumService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Comum>> getComuns() async {
    final response = await http.get(Uri.parse('$baseUrl/comuns'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar comuns: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Comum.fromJson(e)).toList();
  }

  Future<Comum> getComumById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/comuns/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar comum: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return Comum.fromJson(data);
  }

  Future<void> criarComum({
    required String nome,
    String? cidade,
    String? estado,
    String? bairro,
  }) async {
    final body = {
      "nome": nome,
      "cidade": cidade?.trim().isEmpty == true ? null : cidade,
      "estado": estado?.trim().isEmpty == true ? null : estado,
      "bairro": bairro?.trim().isEmpty == true ? null : bairro,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/comuns'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao criar comum: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> editarComum({
    required int id,
    required String nome,
    String? cidade,
    String? estado,
    String? bairro,
  }) async {
    final body = {
      "id": id,
      "nome": nome,
      "cidade": cidade?.trim().isEmpty == true ? null : cidade,
      "estado": estado?.trim().isEmpty == true ? null : estado,
      "bairro": bairro?.trim().isEmpty == true ? null : bairro,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/comuns/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao editar comum: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deletarComum(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/comuns/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir comum: ${response.statusCode} - ${response.body}',
      );
    }
  }
}