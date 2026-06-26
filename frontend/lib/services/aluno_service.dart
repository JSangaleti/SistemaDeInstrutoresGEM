import 'dart:convert';

import '../config/api_config.dart';
import '../models/aluno.dart';
import '../models/comum.dart';

class AlunoService {
  Future<List<Aluno>> getAlunos() async {
    final response = await ApiClient.get('/alunos');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar alunos.',
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Aluno.fromJson(e)).toList();
  }

  Future<Aluno> getMeuPerfil() async {
    final response = await ApiClient.get('/alunos/me');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar meu perfil.',
    );

    final data = jsonDecode(response.body);
    return Aluno.fromJson(data);
  }

  Future<List<Comum>> getComuns() async {
    final response = await ApiClient.get('/comuns');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar comuns.',
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Comum.fromJson(e)).toList();
  }

  Future<void> criarAluno({
    required String cpf,
    required String senha,
    required Set<int> instrumentoIds,
    required int instrumentoPrincipalId,
    required Set<int> metodoIds,
  }) async {
    final alunoBody = {
      "senha": senha,
      "pessoa": {"cpf": cpf},
      "instrumentos": _instrumentosBody(instrumentoIds, instrumentoPrincipalId),
      "metodoIds": metodoIds.toList(),
    };

    final alunoResponse = await ApiClient.post(
      '/alunos',
      jsonEncode(alunoBody),
    );

    ApiClient.ensureSuccess(
      alunoResponse,
      acceptedStatusCodes: [200, 201],
      fallbackMessage: 'Erro ao cadastrar aluno.',
    );
  }

  Future<void> editarAluno({
    required int id,
    required String cpf,
    String? senha,
    required Set<int> instrumentoIds,
    required int instrumentoPrincipalId,
    required Set<int> metodoIds,
  }) async {
    final alunoBody = {
      "pessoa": {"cpf": cpf},
      if (senha != null && senha.trim().isNotEmpty) "senha": senha.trim(),
      "instrumentos": _instrumentosBody(instrumentoIds, instrumentoPrincipalId),
      "metodoIds": metodoIds.toList(),
    };

    final alunoResponse = await ApiClient.put(
      '/alunos/$id',
      jsonEncode(alunoBody),
    );

    ApiClient.ensureSuccess(
      alunoResponse,
      fallbackMessage: 'Erro ao editar aluno.',
    );
  }

  Future<void> deletarAluno(int id) async {
    final response = await ApiClient.delete('/alunos/$id');

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 204],
      fallbackMessage: 'Erro ao excluir aluno.',
    );
  }

  Future<Aluno> getAlunoById(int id) async {
    final response = await ApiClient.get('/alunos/$id');

    ApiClient.ensureSuccess(response, fallbackMessage: 'Erro ao buscar aluno.');

    final data = jsonDecode(response.body);
    return Aluno.fromJson(data);
  }

  List<Map<String, dynamic>> _instrumentosBody(
    Set<int> instrumentoIds,
    int instrumentoPrincipalId,
  ) {
    return instrumentoIds
        .map(
          (id) => {
            'instrumentoId': id,
            'principal': id == instrumentoPrincipalId,
          },
        )
        .toList();
  }
}
