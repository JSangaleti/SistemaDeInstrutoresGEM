import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/aluno.dart';

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
}