import 'package:flutter/material.dart';

import '../../models/instrumento.dart';
import '../../models/metodo.dart';
import '../../services/metodo_service.dart';

class MetodoFormPage extends StatefulWidget {
  final Metodo? metodo;

  const MetodoFormPage({
    super.key,
    this.metodo,
  });

  @override
  State<MetodoFormPage> createState() => _MetodoFormPageState();
}

class _MetodoFormPageState extends State<MetodoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final MetodoService service = MetodoService();

  final TextEditingController nomeController = TextEditingController();

  List<Instrumento> instrumentos = [];
  int? instrumentoSelecionadoId;

  bool loading = true;
  bool salvando = false;
  String? erro;

  bool get isEdicao => widget.metodo != null;

  @override
  void initState() {
    super.initState();

    if (widget.metodo != null) {
      nomeController.text = widget.metodo!.nome;
      instrumentoSelecionadoId = widget.metodo!.instrumentoId;
    }

    carregarInstrumentos();
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  Future<void> carregarInstrumentos() async {
    try {
      final lista = await service.getInstrumentos();

      setState(() {
        instrumentos = lista;
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

    if (instrumentoSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um instrumento')),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      if (isEdicao) {
        await service.editarMetodo(
          id: widget.metodo!.id,
          nome: nomeController.text.trim(),
          instrumentoId: instrumentoSelecionadoId!,
        );
      } else {
        await service.criarMetodo(
          nome: nomeController.text.trim(),
          instrumentoId: instrumentoSelecionadoId!,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar método: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Método' : 'Cadastrar Método'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(child: Text('Erro ao carregar instrumentos:\n$erro'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do método',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            final nome = value?.trim() ?? '';

                            if (nome.isEmpty) {
                              return 'Informe o nome do método';
                            }

                            if (nome.length > 64) {
                              return 'Nome deve ter no máximo 64 caracteres';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: instrumentoSelecionadoId,
                          decoration: const InputDecoration(
                            labelText: 'Instrumento',
                            border: OutlineInputBorder(),
                          ),
                          items: instrumentos.map((instrumento) {
                            return DropdownMenuItem<int>(
                              value: instrumento.id,
                              child: Text(instrumento.nome),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              instrumentoSelecionadoId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Selecione um instrumento';
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
