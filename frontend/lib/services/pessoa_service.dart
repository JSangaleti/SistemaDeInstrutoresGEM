import 'dart:convert';

import '../config/api_config.dart';
import '../models/pessoa.dart';

class PessoaService {
  Future<List<Pessoa>> getPessoas() async {
    final response = await ApiClient.get('/pessoas');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar pessoas: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Pessoa.fromJson(e)).toList();
  }

  Future<Pessoa> getPessoaByCpf(String cpf) async {
    final response = await ApiClient.get('/pessoas/$cpf');

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
      "comum": {"id": comumId},
    };

    final response = await ApiClient.post('/pessoas', jsonEncode(body));

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
      "comum": {"id": comumId},
    };

    final response = await ApiClient.put('/pessoas/$cpf', jsonEncode(body));

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao editar pessoa: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deletarPessoa(String cpf) async {
    final response = await ApiClient.delete('/pessoas/$cpf');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir pessoa: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
