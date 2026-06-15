import 'dart:convert';

import '../config/api_config.dart';
import '../models/comum.dart';

class ComumService {
  Future<List<Comum>> getComuns() async {
    final response = await ApiClient.get('/comuns');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar comuns: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Comum.fromJson(e)).toList();
  }

  Future<Comum> getComumById(int id) async {
    final response = await ApiClient.get('/comuns/$id');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar comum: ${response.statusCode}');
    }

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

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao criar comum: ${response.statusCode} - ${response.body}',
      );
    }
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

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao editar comum: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deletarComum(int id) async {
    final response = await ApiClient.delete('/comuns/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir comum: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
