import 'dart:convert';

import '../config/api_config.dart';
import '../models/admin.dart';

class AdminService {
  Future<List<Admin>> getAdmins() async {
    final response = await ApiClient.get('/admins');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar admins: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Admin.fromJson(e)).toList();
  }

  Future<Admin> getAdminById(int id) async {
    final response = await ApiClient.get('/admins/$id');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar admin: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return Admin.fromJson(data);
  }

  Future<void> criarAdmin({
    required String cpf,
    required String senha,
  }) async {
    final adminBody = {
      "senha": senha,
      "pessoa": {"cpf": cpf},
    };

    final response = await ApiClient.post('/admins', jsonEncode(adminBody));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao cadastrar admin: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> editarAdmin({
    required int id,
    required String cpf,
    String? senha,
  }) async {
    final adminBody = {
      "pessoa": {"cpf": cpf},
      if (senha != null && senha.trim().isNotEmpty) "senha": senha.trim(),
    };

    final response = await ApiClient.put('/admins/$id', jsonEncode(adminBody));

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao editar admin: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deletarAdmin(int id) async {
    final response = await ApiClient.delete('/admins/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erro ao excluir admin: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
