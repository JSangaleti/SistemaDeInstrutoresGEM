import 'dart:convert';

import '../config/api_config.dart';
import '../models/instrumento.dart';

class InstrumentoService {
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

  Future<void> criarInstrumento({required String nome}) async {
    final response = await ApiClient.post(
      '/instrumentos',
      jsonEncode({'nome': nome}),
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
    final response = await ApiClient.put(
      '/instrumentos/$id',
      jsonEncode({'id': id, 'nome': nome}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao editar instrumento: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deletarInstrumento(int id) async {
    final response = await ApiClient.delete('/instrumentos/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir instrumento: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
