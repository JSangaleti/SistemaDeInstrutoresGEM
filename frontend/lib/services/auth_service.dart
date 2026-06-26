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

  Future<void> alterarSenha({
    required String senhaAntiga,
    required String novaSenha,
    required String confirmacaoNovaSenha,
  }) async {
    final response = await ApiClient.put(
      '/auth/senha',
      jsonEncode({
        'senhaAntiga': senhaAntiga.trim(),
        'novaSenha': novaSenha.trim(),
        'confirmacaoNovaSenha': confirmacaoNovaSenha.trim(),
      }),
    );

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 204],
      fallbackMessage: 'Erro ao alterar senha.',
    );
  }

  Future<void> alterarSenhaComoAdmin({
    required String perfil,
    required int usuarioId,
    required String novaSenha,
    required String confirmacaoNovaSenha,
  }) async {
    final response = await ApiClient.put(
      '/auth/admin/senha',
      jsonEncode({
        'perfil': perfil,
        'usuarioId': usuarioId,
        'novaSenha': novaSenha.trim(),
        'confirmacaoNovaSenha': confirmacaoNovaSenha.trim(),
      }),
    );

    ApiClient.ensureSuccess(
      response,
      acceptedStatusCodes: [200, 204],
      fallbackMessage: 'Erro ao alterar senha.',
    );
  }
}
