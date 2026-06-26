import 'dart:convert';

import '../config/api_config.dart';
import '../models/instrutor.dart';

class InstrutorService {
  Future<List<Instrutor>> getInstrutores() async {
    final response = await ApiClient.get('/instrutores');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar instrutores.',
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Instrutor.fromJson(e)).toList();
  }

  Future<Instrutor> getInstrutorById(int id) async {
    final response = await ApiClient.get('/instrutores/$id');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar instrutor.',
    );

    final data = jsonDecode(response.body);
    return Instrutor.fromJson(data);
  }

  Future<Instrutor> getMeuPerfil() async {
    final response = await ApiClient.get('/instrutores/me');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar meu perfil.',
    );

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

    ApiClient.ensureSuccess(
      instrutorResponse,
      acceptedStatusCodes: [200, 201],
      fallbackMessage: 'Erro ao cadastrar instrutor.',
    );
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

    ApiClient.ensureSuccess(
      instrutorResponse,
      fallbackMessage: 'Erro ao editar instrutor.',
    );
  }

  Future<void> deletarInstrutor(int id) async {
    final response = await ApiClient.delete('/instrutores/$id');

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 204],
      fallbackMessage: 'Erro ao excluir instrutor.',
    );
  }
}
