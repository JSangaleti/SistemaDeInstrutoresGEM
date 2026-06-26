import 'dart:convert';

import '../config/api_config.dart';
import '../models/admin.dart';

class AdminService {
  Future<List<Admin>> getAdmins() async {
    final response = await ApiClient.get('/admins');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar administradores.',
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => Admin.fromJson(e)).toList();
  }

  Future<Admin> getAdminById(int id) async {
    final response = await ApiClient.get('/admins/$id');

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao buscar administrador.',
    );

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

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 201],
      fallbackMessage: 'Erro ao cadastrar administrador.',
    );
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

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'Erro ao editar administrador.',
    );
  }

  Future<void> deletarAdmin(int id) async {
    final response = await ApiClient.delete('/admins/$id');

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 204],
      fallbackMessage: 'Erro ao excluir administrador.',
    );
  }
}
