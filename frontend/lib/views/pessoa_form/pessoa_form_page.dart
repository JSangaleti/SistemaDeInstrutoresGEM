import 'package:flutter/material.dart';
import '../../models/comum.dart';
import '../../models/pessoa.dart';
import '../../services/aluno_service.dart';
import '../../services/pessoa_service.dart';

class PessoaFormPage extends StatefulWidget {
  final Pessoa? pessoa;

  const PessoaFormPage({super.key, this.pessoa});

  @override
  State<PessoaFormPage> createState() => _PessoaFormPageState();
}

class _PessoaFormPageState extends State<PessoaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final PessoaService pessoaService = PessoaService();
  final AlunoService alunoService = AlunoService();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();

  List<Comum> comuns = [];
  int? comumSelecionadaId;

  bool loading = true;
  bool salvando = false;
  String? erro;

  @override
  void initState() {
    super.initState();

    if (widget.pessoa != null) {
      nomeController.text = widget.pessoa!.nome;
      cpfController.text = widget.pessoa!.cpf;
    }

    carregarComuns();
  }

  Future<void> carregarComuns() async {
    try {
      final lista = await alunoService.getComuns();

      int? comumIdEncontrada;
      if (widget.pessoa?.comum != null) {
        final match = lista.where((c) => c.nome == widget.pessoa!.comum).toList();
        if (match.isNotEmpty) {
          comumIdEncontrada = match.first.id;
        }
      }

      setState(() {
        comuns = lista;
        comumSelecionadaId = comumIdEncontrada;
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
      if (widget.pessoa == null) {
        await pessoaService.criarPessoa(
          cpf: cpfController.text.trim(),
          nome: nomeController.text.trim(),
          comumId: comumSelecionadaId!,
        );
      } else {
        await pessoaService.editarPessoa(
          cpf: cpfController.text.trim(),
          nome: nomeController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.pessoa != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Pessoa' : 'Cadastrar Pessoa'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(child: Text('Erro ao carregar comuns: $erro'))
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: cpfController,
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: isEdicao,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o CPF';
                            }
                            if (value.trim().length != 11) {
                              return 'CPF deve ter 11 dígitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: comumSelecionadaId,
                          decoration: const InputDecoration(
                            labelText: 'Comum',
                            border: OutlineInputBorder(),
                          ),
                          items: comuns.map((comum) {
                            return DropdownMenuItem<int>(
                              value: comum.id,
                              child: Text(comum.nome),
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
                                : (isEdicao ? 'Salvar alterações' : 'Cadastrar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}