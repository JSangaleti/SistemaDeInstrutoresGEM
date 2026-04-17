import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/aluno.dart';
import '../models/comum.dart';

class AlunoService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Aluno>> getAlunos() async {
    final response = await http.get(Uri.parse('$baseUrl/alunos'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar alunos: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Aluno.fromJson(e)).toList();
  }

  Future<List<Comum>> getComuns() async {
    final response = await http.get(Uri.parse('$baseUrl/comuns'));

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
      "comum": {
        "id": comumId,
      }
    };

    final pessoaResponse = await http.post(
      Uri.parse('$baseUrl/pessoas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pessoaBody),
    );

    if (pessoaResponse.statusCode != 200 && pessoaResponse.statusCode != 201) {
      throw Exception(
        'Erro ao cadastrar pessoa: ${pessoaResponse.statusCode} - ${pessoaResponse.body}',
      );
    }

    final alunoBody = {
      "senha": senha,
      "pessoa": {
        "cpf": cpf,
      },
      "comum": {
        "id": comumId,
      }
    };

    final alunoResponse = await http.post(
      Uri.parse('$baseUrl/alunos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(alunoBody),
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
    required String senha,
    required int comumId,
  }) async {
    final pessoaBody = {
      "cpf": cpf,
      "nome": nome,
      "comum": {
        "id": comumId,
      }
    };

    final pessoaResponse = await http.put(
      Uri.parse('$baseUrl/pessoas/$cpf'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pessoaBody),
    );

    if (pessoaResponse.statusCode != 200) {
      throw Exception(
        'Erro ao editar pessoa: ${pessoaResponse.statusCode} - ${pessoaResponse.body}',
      );
    }

    final alunoBody = {
      "senha": senha,
      "pessoa": {
        "cpf": cpf,
      },
      "comum": {
        "id": comumId,
      }
    };

    final alunoResponse = await http.put(
      Uri.parse('$baseUrl/alunos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(alunoBody),
    );

    if (alunoResponse.statusCode != 200) {
      throw Exception(
        'Erro ao editar aluno: ${alunoResponse.statusCode} - ${alunoResponse.body}',
      );
    }
  }

  Future<void> deletarAluno(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/alunos/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir aluno: ${response.statusCode} - ${response.body}',
      );
    }
  }
  Future<Aluno> getAlunoById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/alunos/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar aluno: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return Aluno.fromJson(data);
  }
}