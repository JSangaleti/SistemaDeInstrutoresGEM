import 'dart:convert';

import '../config/api_config.dart';
import '../models/instrumento.dart';

class InstrumentoService {
  Future<List<Instrumento>> getInstrumentos() async {
    final response = await ApiClient.get('/instrumentos');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar instrumentos.',
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Instrumento.fromJson(e)).toList();
  }

  Future<void> criarInstrumento({required String nome}) async {
    final response = await ApiClient.post(
      '/instrumentos',
      jsonEncode({'nome': nome}),
    );

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 201],
      fallbackMessage: 'Erro ao criar instrumento.',
    );
  }

  Future<void> editarInstrumento({
    required int id,
    required String nome,
  }) async {
    final response = await ApiClient.put(
      '/instrumentos/$id',
      jsonEncode({'id': id, 'nome': nome}),
    );

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao editar instrumento.',
    );
  }

  Future<void> deletarInstrumento(int id) async {
    final response = await ApiClient.delete('/instrumentos/$id');

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 204],
      fallbackMessage: 'Erro ao excluir instrumento.',
    );
  }
}
