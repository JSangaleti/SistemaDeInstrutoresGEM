import 'package:flutter/material.dart';

import '../../models/aluno.dart';
import '../../models/pessoa.dart';
import '../../services/aluno_service.dart';
import '../../services/pessoa_service.dart';
import '../../widgets/searchable_selection.dart';

class AlunoFormPage extends StatefulWidget {
  final Aluno? aluno;

  const AlunoFormPage({super.key, this.aluno});

  @override
  State<AlunoFormPage> createState() => _AlunoFormPageState();
}

class _AlunoFormPageState extends State<AlunoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AlunoService service = AlunoService();
  final PessoaService pessoaService = PessoaService();

  final TextEditingController senhaController = TextEditingController();

  List<Pessoa> pessoas = [];
  String? cpfSelecionado;

  bool loading = true;
  bool salvando = false;
  String? erro;

  bool get isEdicao => widget.aluno != null;

  @override
  void initState() {
    super.initState();

    if (widget.aluno != null) {
      cpfSelecionado = widget.aluno!.cpf;
    }

    carregarPessoas();
  }

  @override
  void dispose() {
    senhaController.dispose();
    super.dispose();
  }

  Future<void> carregarPessoas() async {
    try {
      final lista = await pessoaService.getPessoas();

      setState(() {
        pessoas = lista;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (cpfSelecionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma pessoa')));
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      if (isEdicao) {
        await service.editarAluno(
          id: widget.aluno!.id,
          cpf: cpfSelecionado!,
          senha: senhaController.text.trim(),
        );
      } else {
        await service.criarAluno(
          cpf: cpfSelecionado!,
          senha: senhaController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  String? validarSenha(String? value) {
    final senha = value?.trim() ?? '';

    if (!isEdicao && senha.isEmpty) {
      return 'Informe a senha';
    }

    if (senha.isNotEmpty && senha.length > 16) {
      return 'Senha deve ter no máximo 16 caracteres';
    }

    return null;
  }

  String textoPessoa(Pessoa pessoa) {
    return '${pessoa.nome} - ${pessoa.cpf}';
  }

  Pessoa? pessoaSelecionada() {
    for (final pessoa in pessoas) {
      if (pessoa.cpf == cpfSelecionado) return pessoa;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Aluno' : 'Cadastrar Aluno'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erro ao carregar pessoas:\n$erro',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    SearchableSelectionField<Pessoa>(
                      labelText: 'Pessoa',
                      dialogTitle: 'Selecionar pessoa',
                      items: pessoas,
                      value: pessoaSelecionada(),
                      itemTitle: textoPessoa,
                      itemSubtitle: (pessoa) => pessoa.comumCompleta,
                      itemSearchText: (pessoa) =>
                          '${pessoa.nome} ${pessoa.cpf} ${pessoa.comumCompleta}',
                      searchHintText: 'Buscar por nome, CPF ou comum...',
                      onChanged: (pessoa) {
                        setState(() {
                          cpfSelecionado = pessoa?.cpf;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione uma pessoa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: isEdicao ? 'Nova senha (opcional)' : 'Senha',
                        border: const OutlineInputBorder(),
                      ),
                      validator: validarSenha,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: salvando ? null : salvar,
                      child: Text(
                        salvando
                            ? 'Salvando...'
                            : isEdicao
                            ? 'Salvar alterações'
                            : 'Cadastrar',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
