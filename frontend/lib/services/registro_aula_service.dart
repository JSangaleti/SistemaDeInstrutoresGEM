import 'dart:convert';

import '../config/api_config.dart';
import '../models/aluno.dart';
import '../models/instrutor.dart';
import '../models/registro_aula.dart';

class RegistroAulaService {
  Future<List<RegistroAula>> getRegistrosAula() async {
    final response = await ApiClient.get('/registro-aulas');

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar registros de aula: ${response.statusCode} - ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return _ordenarPorDataDesc(
      data.map((e) => RegistroAula.fromJson(e)).toList(),
    );
  }

  Future<List<RegistroAula>> getMeuHistorico() async {
    final response = await ApiClient.get('/registro-aulas/meu-historico');

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar meu histórico: ${response.statusCode} - ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return _ordenarPorDataDesc(
      data.map((e) => RegistroAula.fromJson(e)).toList(),
    );
  }

  Future<List<Aluno>> getAlunos() async {
    final response = await ApiClient.get('/alunos');

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar alunos: ${response.statusCode} - ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Aluno.fromJson(e)).toList();
  }

  Future<List<Instrutor>> getInstrutores() async {
    final response = await ApiClient.get('/instrutores');

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar instrutores: ${response.statusCode} - ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Instrutor.fromJson(e)).toList();
  }

  Future<void> criarRegistroAula({
    required int alunoId,
    required int instrutorId,
    required DateTime data,
    required int presente,
    required String descricao,
    required String paraProximaAula,
  }) async {
    final response = await ApiClient.post(
      '/registro-aulas',
      jsonEncode(
        _body(
          alunoId: alunoId,
          instrutorId: instrutorId,
          data: data,
          presente: presente,
          descricao: descricao,
          paraProximaAula: paraProximaAula,
        ),
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao criar registro de aula: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> editarRegistroAula({
    required int id,
    required int alunoId,
    required int instrutorId,
    required DateTime data,
    required int presente,
    required String descricao,
    String? paraProximaAula,
  }) async {
    final response = await ApiClient.put(
      '/registro-aulas/$id',
      jsonEncode({
        'id': id,
        ..._body(
          alunoId: alunoId,
          instrutorId: instrutorId,
          data: data,
          presente: presente,
          descricao: descricao,
          paraProximaAula: paraProximaAula,
        ),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao editar registro de aula: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deletarRegistroAula(int id) async {
    final response = await ApiClient.delete('/registro-aulas/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir registro de aula: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Map<String, dynamic> _body({
    required int alunoId,
    required int instrutorId,
    required DateTime data,
    required int presente,
    required String descricao,
    String? paraProximaAula,
  }) {
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');

    final body = {
      'aluno': {'id': alunoId},
      'instrutor': {'id': instrutorId},
      'data': '${data.year}-$mes-$dia',
      'presente': presente,
      'descricao': descricao,
    };

    if (paraProximaAula != null) {
      body['paraProximaAula'] = paraProximaAula;
    }

    return body;
  }

  List<RegistroAula> _ordenarPorDataDesc(List<RegistroAula> registros) {
    registros.sort((a, b) {
      final dataA = a.data ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dataB = b.data ?? DateTime.fromMillisecondsSinceEpoch(0);
      final porData = dataB.compareTo(dataA);
      if (porData != 0) return porData;
      return b.id.compareTo(a.id);
    });
    return registros;
  }
}
