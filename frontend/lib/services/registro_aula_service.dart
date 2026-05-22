import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/aluno.dart';
import '../models/instrutor.dart';
import '../models/registro_aula.dart';

class RegistroAulaService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<RegistroAula>> getRegistrosAula() async {
    final response = await http.get(Uri.parse('$baseUrl/registro-aulas'));

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar registros de aula: ${response.statusCode} - ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => RegistroAula.fromJson(e)).toList();
  }

  Future<List<Aluno>> getAlunos() async {
    final response = await http.get(Uri.parse('$baseUrl/alunos'));

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar alunos: ${response.statusCode} - ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Aluno.fromJson(e)).toList();
  }

  Future<List<Instrutor>> getInstrutores() async {
    final response = await http.get(Uri.parse('$baseUrl/instrutores'));

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
    final response = await http.post(
      Uri.parse('$baseUrl/registro-aulas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
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
    final response = await http.put(
      Uri.parse('$baseUrl/registro-aulas/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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
    final response = await http.delete(
      Uri.parse('$baseUrl/registro-aulas/$id'),
    );

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
}
