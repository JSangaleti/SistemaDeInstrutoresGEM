import 'package:flutter/material.dart';

import '../../models/instrutor.dart';
import '../../models/pessoa.dart';
import '../../services/instrutor_service.dart';
import '../../services/pessoa_service.dart';
import '../../widgets/searchable_selection.dart';

class InstrutorFormPage extends StatefulWidget {
  final Instrutor? instrutor;

  const InstrutorFormPage({super.key, this.instrutor});

  @override
  State<InstrutorFormPage> createState() => _InstrutorFormPageState();
}

class _InstrutorFormPageState extends State<InstrutorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final InstrutorService service = InstrutorService();
  final PessoaService pessoaService = PessoaService();

  final TextEditingController senhaController = TextEditingController();

  List<Pessoa> pessoas = [];
  String? cpfSelecionado;

  bool loading = true;
  bool salvando = false;
  String? erro;

  bool get isEdicao => widget.instrutor != null;

  @override
  void initState() {
    super.initState();

    if (widget.instrutor != null) {
      cpfSelecionado = widget.instrutor!.cpf;
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
        await service.editarInstrutor(
          id: widget.instrutor!.id,
          cpf: cpfSelecionado!,
          senha: senhaController.text.trim(),
        );
      } else {
        await service.criarInstrutor(
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
        title: Text(isEdicao ? 'Editar Instrutor' : 'Cadastrar Instrutor'),
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
                    const SizedBox(height: 16),
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
