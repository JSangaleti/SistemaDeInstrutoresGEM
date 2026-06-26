import 'dart:convert';

import '../config/api_config.dart';
import '../models/comum.dart';

class ComumService {
  Future<List<Comum>> getComuns() async {
    final response = await ApiClient.get('/comuns');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar comuns.',
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Comum.fromJson(e)).toList();
  }

  Future<Comum> getComumById(int id) async {
    final response = await ApiClient.get('/comuns/$id');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar comum.',
    );

    final data = jsonDecode(response.body);
    return Comum.fromJson(data);
  }

  Future<void> criarComum({
    required String nome,
    String? cidade,
    String? estado,
    String? bairro,
  }) async {
    final body = {
      "nome": nome,
      "cidade": cidade?.trim().isEmpty == true ? null : cidade,
      "estado": estado?.trim().isEmpty == true ? null : estado,
      "bairro": bairro?.trim().isEmpty == true ? null : bairro,
    };

    final response = await ApiClient.post('/comuns', jsonEncode(body));

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 201],
      fallbackMessage: 'Erro ao criar comum.',
    );
  }

  Future<void> editarComum({
    required int id,
    required String nome,
    String? cidade,
    String? estado,
    String? bairro,
  }) async {
    final body = {
      "id": id,
      "nome": nome,
      "cidade": cidade?.trim().isEmpty == true ? null : cidade,
      "estado": estado?.trim().isEmpty == true ? null : estado,
      "bairro": bairro?.trim().isEmpty == true ? null : bairro,
    };

    final response = await ApiClient.put('/comuns/$id', jsonEncode(body));

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao editar comum.',
    );
  }

  Future<void> deletarComum(int id) async {
    final response = await ApiClient.delete('/comuns/$id');

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 204],
      fallbackMessage: 'Erro ao excluir comum.',
    );
  }
}
