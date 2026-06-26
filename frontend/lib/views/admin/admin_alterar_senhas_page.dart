import 'package:flutter/material.dart';

import '../../models/admin.dart';
import '../../models/aluno.dart';
import '../../models/instrutor.dart';
import '../../services/admin_service.dart';
import '../../services/aluno_service.dart';
import '../../services/auth_service.dart';
import '../../services/instrutor_service.dart';
import '../../widgets/searchable_selection.dart';

class AdminAlterarSenhasPage extends StatefulWidget {
  const AdminAlterarSenhasPage({super.key});

  @override
  State<AdminAlterarSenhasPage> createState() => _AdminAlterarSenhasPageState();
}

class _AdminAlterarSenhasPageState extends State<AdminAlterarSenhasPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _alunoService = AlunoService();
  final _instrutorService = InstrutorService();
  final _adminService = AdminService();
  final _novaSenhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();

  final List<_UsuarioSenha> _usuarios = [];
  String _perfilSelecionado = 'ALUNO';
  _UsuarioSenha? _usuarioSelecionado;
  bool _loading = true;
  bool _salvando = false;
  bool _ocultarNovaSenha = true;
  bool _ocultarConfirmacao = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _novaSenhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuarios() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final resultados = await Future.wait([
        _alunoService.getAlunos(),
        _instrutorService.getInstrutores(),
        _adminService.getAdmins(),
      ]);

      final alunos = resultados[0] as List<Aluno>;
      final instrutores = resultados[1] as List<Instrutor>;
      final admins = resultados[2] as List<Admin>;

      final usuarios =
          <_UsuarioSenha>[
            ...alunos.map(
              (aluno) => _UsuarioSenha(
                id: aluno.id,
                nome: aluno.nome,
                cpf: aluno.cpf,
                perfil: 'ALUNO',
                perfilTexto: 'Aluno',
              ),
            ),
            ...instrutores.map(
              (instrutor) => _UsuarioSenha(
                id: instrutor.id,
                nome: instrutor.nome,
                cpf: instrutor.cpf,
                perfil: 'INSTRUTOR',
                perfilTexto: 'Instrutor',
              ),
            ),
            ...admins.map(
              (admin) => _UsuarioSenha(
                id: admin.id,
                nome: admin.nome,
                cpf: admin.cpf,
                perfil: 'ADMIN',
                perfilTexto: 'Administrador',
              ),
            ),
          ]..sort((a, b) {
            final perfil = a.perfilTexto.compareTo(b.perfilTexto);
            if (perfil != 0) return perfil;
            return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
          });

      if (!mounted) return;
      setState(() {
        _usuarios
          ..clear()
          ..addAll(usuarios);
        _usuarioSelecionado = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString();
        _loading = false;
      });
    }
  }

  List<_UsuarioSenha> get _usuariosDoPerfil {
    return _usuarios
        .where((usuario) => usuario.perfil == _perfilSelecionado)
        .toList();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = _usuarioSelecionado;
    if (usuario == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um usuário.')));
      return;
    }

    setState(() => _salvando = true);

    try {
      await _authService.alterarSenhaComoAdmin(
        perfil: usuario.perfil,
        usuarioId: usuario.id,
        novaSenha: _novaSenhaController.text.trim(),
        confirmacaoNovaSenha: _confirmacaoController.text.trim(),
      );

      _novaSenhaController.clear();
      _confirmacaoController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha de ${usuario.nome} alterada.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao alterar senha: $e')));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar senhas'),
        actions: [
          IconButton(
            onPressed: _carregarUsuarios,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar usuários:\n$_erro',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'ALUNO',
                        icon: Icon(Icons.school),
                        label: Text('Alunos'),
                      ),
                      ButtonSegment(
                        value: 'INSTRUTOR',
                        icon: Icon(Icons.co_present),
                        label: Text('Instrutores'),
                      ),
                      ButtonSegment(
                        value: 'ADMIN',
                        icon: Icon(Icons.admin_panel_settings),
                        label: Text('Admins'),
                      ),
                    ],
                    selected: {_perfilSelecionado},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _perfilSelecionado = selection.first;
                        _usuarioSelecionado = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SearchableSelectionField<_UsuarioSenha>(
                    key: ValueKey(_perfilSelecionado),
                    labelText: 'Usuário',
                    dialogTitle: 'Selecionar usuário',
                    items: _usuariosDoPerfil,
                    value: _usuarioSelecionado,
                    itemTitle: (usuario) => usuario.nome,
                    itemSubtitle: (usuario) =>
                        '${usuario.perfilTexto}${usuario.cpf == null ? '' : ' - ${usuario.cpf}'}',
                    itemSearchText: (usuario) =>
                        '${usuario.nome} ${usuario.cpf ?? ''} ${usuario.perfilTexto}',
                    searchHintText: 'Buscar por nome, CPF ou perfil...',
                    emptyText: 'Nenhum usuário encontrado.',
                    onChanged: (usuario) {
                      setState(() {
                        _usuarioSelecionado = usuario;
                      });
                    },
                    validator: (usuario) =>
                        usuario == null ? 'Selecione um usuário.' : null,
                  ),
                  const SizedBox(height: 16),
                  _SenhaField(
                    controller: _novaSenhaController,
                    label: 'Nova senha',
                    obscureText: _ocultarNovaSenha,
                    onToggleVisibility: () =>
                        setState(() => _ocultarNovaSenha = !_ocultarNovaSenha),
                  ),
                  const SizedBox(height: 16),
                  _SenhaField(
                    controller: _confirmacaoController,
                    label: 'Confirmar nova senha',
                    obscureText: _ocultarConfirmacao,
                    onToggleVisibility: () => setState(
                      () => _ocultarConfirmacao = !_ocultarConfirmacao,
                    ),
                    validator: (value) {
                      final texto = value?.trim() ?? '';
                      if (texto.isEmpty) return 'Confirme a nova senha.';
                      if (texto != _novaSenhaController.text.trim()) {
                        return 'A confirmação não confere.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_reset),
                    label: const Text('Alterar senha'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _UsuarioSenha {
  final int id;
  final String nome;
  final String? cpf;
  final String perfil;
  final String perfilTexto;

  const _UsuarioSenha({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.perfil,
    required this.perfilTexto,
  });
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
