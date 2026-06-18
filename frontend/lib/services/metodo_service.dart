import 'dart:convert';

import '../config/api_config.dart';
import '../models/instrumento.dart';
import '../models/metodo.dart';

class MetodoService {
  Future<List<Metodo>> getMetodos() async {
    final response = await ApiClient.get('/metodos');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar métodos.',
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Metodo.fromJson(e)).toList();
  }

  Future<List<Instrumento>> getInstrumentos() async {
    final response = await ApiClient.get('/instrumentos');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar instrumentos.',
    );

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

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 201],
      fallbackMessage: 'Erro ao criar método.',
    );
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

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao editar método.',
    );
  }

  Future<void> deletarMetodo(int id) async {
    final response = await ApiClient.delete('/metodos/$id');

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 204],
      fallbackMessage: 'Erro ao excluir método.',
    );
  }
}
