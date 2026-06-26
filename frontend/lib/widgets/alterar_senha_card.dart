import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AlterarSenhaCard extends StatefulWidget {
  const AlterarSenhaCard({super.key});

  @override
  State<AlterarSenhaCard> createState() => _AlterarSenhaCardState();
}

class _AlterarSenhaCardState extends State<AlterarSenhaCard> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _senhaAntigaController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();

  bool _salvando = false;
  bool _ocultarSenhaAntiga = true;
  bool _ocultarNovaSenha = true;
  bool _ocultarConfirmacao = true;

  @override
  void dispose() {
    _senhaAntigaController.dispose();
    _novaSenhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  Future<void> _alterarSenha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      await _authService.alterarSenha(
        senhaAntiga: _senhaAntigaController.text.trim(),
        novaSenha: _novaSenhaController.text.trim(),
        confirmacaoNovaSenha: _confirmacaoController.text.trim(),
      );

      _senhaAntigaController.clear();
      _novaSenhaController.clear();
      _confirmacaoController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_reset),
                title: Text(
                  'Alterar senha',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              _SenhaField(
                controller: _senhaAntigaController,
                label: 'Senha antiga',
                obscureText: _ocultarSenhaAntiga,
                onToggleVisibility: () =>
                    setState(() => _ocultarSenhaAntiga = !_ocultarSenhaAntiga),
              ),
              const SizedBox(height: 12),
              _SenhaField(
                controller: _novaSenhaController,
                label: 'Nova senha',
                obscureText: _ocultarNovaSenha,
                onToggleVisibility: () =>
                    setState(() => _ocultarNovaSenha = !_ocultarNovaSenha),
              ),
              const SizedBox(height: 12),
              _SenhaField(
                controller: _confirmacaoController,
                label: 'Confirmar nova senha',
                obscureText: _ocultarConfirmacao,
                onToggleVisibility: () =>
                    setState(() => _ocultarConfirmacao = !_ocultarConfirmacao),
                validator: (value) {
                  final texto = value?.trim() ?? '';
                  if (texto.isEmpty) return 'Informe a confirmação da senha.';
                  if (texto != _novaSenhaController.text.trim()) {
                    return 'A confirmação não confere.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _salvando ? null : _alterarSenha,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Salvar nova senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SenhaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  const _SenhaField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          tooltip: obscureText ? 'Mostrar senha' : 'Ocultar senha',
        ),
      ),
      validator:
          validator ??
          (value) {
            if ((value?.trim() ?? '').isEmpty) {
              return 'Informe ${label.toLowerCase()}.';
            }
            return null;
          },
    );
  }
}
