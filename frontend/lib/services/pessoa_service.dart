import 'dart:convert';

import '../config/api_config.dart';
import '../models/pessoa.dart';

class PessoaService {
  Future<List<Pessoa>> getPessoas() async {
    final response = await ApiClient.get('/pessoas');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar pessoas.',
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Pessoa.fromJson(e)).toList();
  }

  Future<Pessoa> getPessoaByCpf(String cpf) async {
    final response = await ApiClient.get('/pessoas/$cpf');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar pessoa.',
    );

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

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 201],
      fallbackMessage: 'Erro ao criar pessoa.',
    );
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

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao editar pessoa.',
    );
  }

  Future<void> deletarPessoa(String cpf) async {
    final response = await ApiClient.delete('/pessoas/$cpf');

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 204],
      fallbackMessage: 'Erro ao excluir pessoa.',
    );
  }
}
