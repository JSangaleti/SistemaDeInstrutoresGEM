import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../admin/admin_home_page.dart';
import '../aluno_area/aluno_home_page.dart';
import '../instrutor_panel/instrutor_panel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();

  String _perfil = 'ALUNO';
  bool _loading = false;
  String? _erro;

  @override
  void dispose() {
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      await _authService.login(
        cpf: _cpfController.text.trim(),
        senha: _senhaController.text,
        perfil: _perfil,
      );

      if (!mounted) return;

      final page = switch (_perfil) {
        'ADMIN' => const AdminHomePage(),
        'INSTRUTOR' => const InstrutorPanelPage(),
        _ => const AlunoHomePage(),
      };

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } catch (e) {
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.music_note,
                        color: colorScheme.onPrimary,
                        size: 40,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sistema GEM',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entre com CPF, senha e perfil para acessar sua área.',
                        style: TextStyle(color: colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Login',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'ALUNO',
                                label: Text('Aluno'),
                                icon: Icon(Icons.school),
                              ),
                              ButtonSegment(
                                value: 'INSTRUTOR',
                                label: Text('Instrutor'),
                                icon: Icon(Icons.co_present),
                              ),
                              ButtonSegment(
                                value: 'ADMIN',
                                label: Text('Admin'),
                                icon: Icon(Icons.admin_panel_settings),
                              ),
                            ],
                            selected: {_perfil},
                            onSelectionChanged: (value) {
                              setState(() {
                                _perfil = value.first;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cpfController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'CPF',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            validator: (value) {
                              final cpf = value?.trim() ?? '';
                              if (cpf.length != 11) {
                                return 'Informe um CPF com 11 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _senhaController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            validator: (value) {
                              if ((value ?? '').isEmpty) {
                                return 'Informe a senha';
                              }
                              return null;
                            },
                          ),
                          if (_erro != null) ...[
                            const SizedBox(height: 12),
                            _MensagemErro(texto: _erro!),
                          ],
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _loading ? null : _entrar,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(_loading ? 'Entrando...' : 'Entrar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MensagemErro extends StatelessWidget {
  final String texto;

  const _MensagemErro({required this.texto});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
