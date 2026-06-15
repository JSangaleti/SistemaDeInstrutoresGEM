import 'dart:convert';

import '../config/api_config.dart';

class AuthService {
  Future<void> login({
    required String cpf,
    required String senha,
    required String perfil,
  }) async {
    final response = await ApiClient.post(
      '/auth/login',
      jsonEncode({'cpf': cpf, 'senha': senha, 'perfil': perfil}),
    );

    if (response.statusCode != 200) {
      throw Exception('CPF, senha ou perfil inválido.');
    }

    AuthSession.salvar(jsonDecode(response.body));
  }

  void logout() {
    AuthSession.limpar();
  }
}
