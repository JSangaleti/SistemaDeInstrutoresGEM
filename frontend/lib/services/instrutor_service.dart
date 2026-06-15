import 'dart:convert';

import '../config/api_config.dart';
import '../models/comum.dart';
import '../models/instrutor.dart';

class InstrutorService {
  Future<List<Instrutor>> getInstrutores() async {
    final response = await ApiClient.get('/instrutores');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar instrutores: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Instrutor.fromJson(e)).toList();
  }

  Future<Instrutor> getInstrutorById(int id) async {
    final response = await ApiClient.get('/instrutores/$id');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar instrutor: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return Instrutor.fromJson(data);
  }

  Future<List<Comum>> getComuns() async {
    final response = await ApiClient.get('/comuns');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar comuns: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Comum.fromJson(e)).toList();
  }

  Future<void> criarInstrutor({
    required String nome,
    required String cpf,
    required String senha,
    required int comumId,
  }) async {
    final pessoaBody = {
      "cpf": cpf,
      "nome": nome,
      "comum": {"id": comumId},
    };

    final pessoaResponse = await ApiClient.post(
      '/pessoas',
      jsonEncode(pessoaBody),
    );

    if (pessoaResponse.statusCode != 200 && pessoaResponse.statusCode != 201) {
      throw Exception(
        'Erro ao cadastrar pessoa: ${pessoaResponse.statusCode} - ${pessoaResponse.body}',
      );
    }

    final instrutorBody = {
      "senha": senha,
      "pessoa": {"cpf": cpf},
    };

    final instrutorResponse = await ApiClient.post(
      '/instrutores',
      jsonEncode(instrutorBody),
    );

    if (instrutorResponse.statusCode != 200 &&
        instrutorResponse.statusCode != 201) {
      throw Exception(
        'Erro ao cadastrar instrutor: ${instrutorResponse.statusCode} - ${instrutorResponse.body}',
      );
    }
  }

  Future<void> editarInstrutor({
    required int id,
    required String nome,
    required String cpf,
    required int comumId,
  }) async {
    final pessoaBody = {
      "cpf": cpf,
      "nome": nome,
      "comum": {"id": comumId},
    };

    final pessoaResponse = await ApiClient.put(
      '/pessoas/$cpf',
      jsonEncode(pessoaBody),
    );

    if (pessoaResponse.statusCode != 200) {
      throw Exception(
        'Erro ao editar pessoa: ${pessoaResponse.statusCode} - ${pessoaResponse.body}',
      );
    }

    final instrutorBody = {
      "pessoa": {"cpf": cpf},
    };

    final instrutorResponse = await ApiClient.put(
      '/instrutores/$id',
      jsonEncode(instrutorBody),
    );

    if (instrutorResponse.statusCode != 200) {
      throw Exception(
        'Erro ao editar instrutor: ${instrutorResponse.statusCode} - ${instrutorResponse.body}',
      );
    }
  }

  Future<void> deletarInstrutor(int id) async {
    final response = await ApiClient.delete('/instrutores/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir instrutor: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
