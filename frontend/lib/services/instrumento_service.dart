import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/instrumento.dart';

class InstrumentoService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Instrumento>> getInstrumentos() async {
    final response = await http.get(Uri.parse('$baseUrl/instrumentos'));

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar instrumentos: ${response.statusCode} - ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Instrumento.fromJson(e)).toList();
  }

  Future<void> criarInstrumento({
    required String nome,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/instrumentos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao criar instrumento: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> editarInstrumento({
    required int id,
    required String nome,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/instrumentos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'nome': nome,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao editar instrumento: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deletarInstrumento(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/instrumentos/$id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir instrumento: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
