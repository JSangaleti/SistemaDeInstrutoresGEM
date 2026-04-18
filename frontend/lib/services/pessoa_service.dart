import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pessoa.dart';

class PessoaService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Pessoa>> getPessoas() async {
    final response = await http.get(Uri.parse('$baseUrl/pessoas'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar pessoas: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Pessoa.fromJson(e)).toList();
  }

  Future<Pessoa> getPessoaByCpf(String cpf) async {
    final response = await http.get(Uri.parse('$baseUrl/pessoas/$cpf'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar pessoa: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return Pessoa.fromJson(data);
  }

  Future<void> criarPessoa({
    required String cpf,
    required String nome,
    required int comumId,
  }) async {
    final body = {
      "cpf": cpf,
      "nome": nome,
      "comum": {
        "id": comumId,
      }
    };

    final response = await http.post(
      Uri.parse('$baseUrl/pessoas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao criar pessoa: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> editarPessoa({
    required String cpf,
    required String nome,
    required int comumId,
  }) async {
    final body = {
      "cpf": cpf,
      "nome": nome,
      "comum": {
        "id": comumId,
      }
    };

    final response = await http.put(
      Uri.parse('$baseUrl/pessoas/$cpf'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao editar pessoa: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deletarPessoa(String cpf) async {
    final response = await http.delete(Uri.parse('$baseUrl/pessoas/$cpf'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir pessoa: ${response.statusCode} - ${response.body}',
      );
    }
  }
}