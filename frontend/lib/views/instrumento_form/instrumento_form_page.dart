import 'package:flutter/material.dart';

import '../../models/instrumento.dart';
import '../../services/instrumento_service.dart';

class InstrumentoFormPage extends StatefulWidget {
  final Instrumento? instrumento;

  const InstrumentoFormPage({super.key, this.instrumento});

  @override
  State<InstrumentoFormPage> createState() => _InstrumentoFormPageState();
}

class _InstrumentoFormPageState extends State<InstrumentoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final InstrumentoService service = InstrumentoService();

  final TextEditingController nomeController = TextEditingController();

  bool salvando = false;

  bool get isEdicao => widget.instrumento != null;

  @override
  void initState() {
    super.initState();

    if (widget.instrumento != null) {
      nomeController.text = widget.instrumento!.nome;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      salvando = true;
    });

    try {
      if (isEdicao) {
        await service.editarInstrumento(
          id: widget.instrumento!.id,
          nome: nomeController.text.trim(),
        );
      } else {
        await service.criarInstrumento(nome: nomeController.text.trim());
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar instrumento: $e')));
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
        title: Text(isEdicao ? 'Editar Instrumento' : 'Cadastrar Instrumento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do instrumento',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  final nome = value?.trim() ?? '';

                  if (nome.isEmpty) {
                    return 'Informe o nome do instrumento';
                  }

                  if (nome.length > 32) {
                    return 'Nome deve ter no máximo 32 caracteres';
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
