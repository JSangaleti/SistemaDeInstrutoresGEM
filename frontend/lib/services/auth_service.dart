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

    ApiClient.ensureSuccess(
      response,
      fallbackMessage: 'CPF, senha ou perfil inválido.',
    );

    await AuthSession.salvar(jsonDecode(response.body));
  }

  Future<void> logout() async {
    await AuthSession.limpar();
  }
}
