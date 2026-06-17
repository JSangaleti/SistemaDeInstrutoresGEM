import 'dart:convert';

import '../config/api_config.dart';
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

  Future<void> criarInstrutor({
    required String cpf,
    required String senha,
  }) async {
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
    required String cpf,
    String? senha,
  }) async {
    final instrutorBody = {
      "pessoa": {"cpf": cpf},
      if (senha != null && senha.trim().isNotEmpty) "senha": senha.trim(),
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
