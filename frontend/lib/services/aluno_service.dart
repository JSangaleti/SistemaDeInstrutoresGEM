import 'dart:convert';

import '../config/api_config.dart';
import '../models/aluno.dart';
import '../models/comum.dart';

class AlunoService {
  Future<List<Aluno>> getAlunos() async {
    final response = await ApiClient.get('/alunos');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar alunos: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Aluno.fromJson(e)).toList();
  }

  Future<Aluno> getMeuPerfil() async {
    final response = await ApiClient.get('/alunos/me');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar meu perfil: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return Aluno.fromJson(data);
  }

  Future<List<Comum>> getComuns() async {
    final response = await ApiClient.get('/comuns');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar comuns: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Comum.fromJson(e)).toList();
  }

  Future<void> criarAluno({
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

    final alunoBody = {
      "senha": senha,
      "pessoa": {"cpf": cpf},
      "comum": {"id": comumId},
    };

    final alunoResponse = await ApiClient.post(
      '/alunos',
      jsonEncode(alunoBody),
    );

    if (alunoResponse.statusCode != 200 && alunoResponse.statusCode != 201) {
      throw Exception(
        'Erro ao cadastrar aluno: ${alunoResponse.statusCode} - ${alunoResponse.body}',
      );
    }
  }

  Future<void> editarAluno({
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

    final alunoBody = {
      "pessoa": {"cpf": cpf},
      "comum": {"id": comumId},
    };

    final alunoResponse = await ApiClient.put(
      '/alunos/$id',
      jsonEncode(alunoBody),
    );

    if (alunoResponse.statusCode != 200) {
      throw Exception(
        'Erro ao editar aluno: ${alunoResponse.statusCode} - ${alunoResponse.body}',
      );
    }
  }

  Future<void> deletarAluno(int id) async {
    final response = await ApiClient.delete('/alunos/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir aluno: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Aluno> getAlunoById(int id) async {
    final response = await ApiClient.get('/alunos/$id');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar aluno: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return Aluno.fromJson(data);
  }
}
