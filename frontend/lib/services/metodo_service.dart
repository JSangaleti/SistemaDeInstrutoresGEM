import 'dart:convert';

import '../config/api_config.dart';
import '../models/instrumento.dart';
import '../models/metodo.dart';

class MetodoService {
  Future<List<Metodo>> getMetodos() async {
    final response = await ApiClient.get('/metodos');

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar métodos: ${response.statusCode} - ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Metodo.fromJson(e)).toList();
  }

  Future<List<Instrumento>> getInstrumentos() async {
    final response = await ApiClient.get('/instrumentos');

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar instrumentos: ${response.statusCode} - ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Instrumento.fromJson(e)).toList();
  }

  Future<void> criarMetodo({
    required String nome,
    required int instrumentoId,
  }) async {
    final response = await ApiClient.post(
      '/metodos',
      jsonEncode({
        'nome': nome,
        'instrumento': {'id': instrumentoId},
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao criar método: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> editarMetodo({
    required int id,
    required String nome,
    required int instrumentoId,
  }) async {
    final response = await ApiClient.put(
      '/metodos/$id',
      jsonEncode({
        'id': id,
        'nome': nome,
        'instrumento': {'id': instrumentoId},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao editar método: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deletarMetodo(int id) async {
    final response = await ApiClient.delete('/metodos/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir método: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
