import 'package:flutter/material.dart';

import '../../models/aluno.dart';
import '../../models/comum.dart';
import '../../services/aluno_service.dart';

class AlunoFormPage extends StatefulWidget {
  final Aluno? aluno;

  const AlunoFormPage({super.key, this.aluno});

  @override
  State<AlunoFormPage> createState() => _AlunoFormPageState();
}

class _AlunoFormPageState extends State<AlunoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AlunoService service = AlunoService();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  List<Comum> comuns = [];
  int? comumSelecionadaId;

  bool loading = true;
  bool salvando = false;
  String? erro;

  bool get isEdicao => widget.aluno != null;

  @override
  void initState() {
    super.initState();

    if (widget.aluno != null) {
      nomeController.text = widget.aluno!.nome;
      cpfController.text = widget.aluno!.cpf ?? '';
      comumSelecionadaId = widget.aluno!.comumId;
    }

    carregarComuns();
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> carregarComuns() async {
    try {
      final lista = await service.getComuns();

      setState(() {
        comuns = lista;
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

    if (comumSelecionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma comum')),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      if (isEdicao) {
        await service.editarAluno(
          id: widget.aluno!.id,
          nome: nomeController.text.trim(),
          cpf: cpfController.text.trim(),
          comumId: comumSelecionadaId!,
        );
      } else {
        await service.criarAluno(
          nome: nomeController.text.trim(),
          cpf: cpfController.text.trim(),
          senha: senhaController.text.trim(),
          comumId: comumSelecionadaId!,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  String? validarCpf(String? value) {
    final cpf = value?.trim() ?? '';

    if (cpf.isEmpty) {
      return 'Informe o CPF';
    }

    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cpf)) {
      return 'CPF deve conter apenas números';
    }

    return null;
  }

  String? validarSenha(String? value) {
    if (isEdicao) return null;

    final senha = value?.trim() ?? '';

    if (senha.isEmpty) {
      return 'Informe a senha';
    }

    if (senha.length > 16) {
      return 'Senha deve ter no máximo 16 caracteres';
    }

    return null;
  }

  String textoComum(Comum comum) {
    final partes = <String>[
      comum.nome,
      comum.cidade ?? '',
      comum.estado ?? '',
    ].where((item) => item.trim().isNotEmpty).toList();

    return partes.join(' - ');
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
                      'Erro ao carregar comuns:\n$erro',
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
                        TextFormField(
                          controller: nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome';
                            }

                            if (value.trim().length > 64) {
                              return 'Nome deve ter no máximo 64 caracteres';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: cpfController,
                          enabled: !isEdicao,
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                            border: OutlineInputBorder(),
                            helperText: 'Digite apenas números',
                          ),
                          keyboardType: TextInputType.number,
                          validator: validarCpf,
                        ),
                        const SizedBox(height: 16),
                        if (!isEdicao) ...[
                          TextFormField(
                            controller: senhaController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(),
                            ),
                            validator: validarSenha,
                          ),
                          const SizedBox(height: 16),
                        ],
                        DropdownButtonFormField<int>(
                          initialValue: comumSelecionadaId,
                          decoration: const InputDecoration(
                            labelText: 'Comum',
                            border: OutlineInputBorder(),
                          ),
                          items: comuns.map((comum) {
                            return DropdownMenuItem<int>(
                              value: comum.id,
                              child: Text(textoComum(comum)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              comumSelecionadaId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Selecione uma comum';
                            }
                            return null;
                          },
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