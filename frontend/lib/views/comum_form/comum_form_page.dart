import 'package:flutter/material.dart';
import '../../models/comum.dart';
import '../../services/comum_service.dart';

class ComumFormPage extends StatefulWidget {
  final Comum? comum;

  const ComumFormPage({super.key, this.comum});

  @override
  State<ComumFormPage> createState() => _ComumFormPageState();
}

class _ComumFormPageState extends State<ComumFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ComumService service = ComumService();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();

  final List<String> estados = const [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];

  String? estadoSelecionado;
  bool salvando = false;

  @override
  void initState() {
    super.initState();

    if (widget.comum != null) {
      nomeController.text = widget.comum!.nome;
      cidadeController.text = widget.comum!.cidade ?? '';
      bairroController.text = widget.comum!.bairro ?? '';
      estadoSelecionado = widget.comum!.estado;
    }
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      salvando = true;
    });

    try {
      if (widget.comum == null) {
        await service.criarComum(
          nome: nomeController.text.trim(),
          cidade: cidadeController.text.trim(),
          estado: estadoSelecionado,
          bairro: bairroController.text.trim(),
        );
      } else {
        await service.editarComum(
          id: widget.comum!.id,
          nome: nomeController.text.trim(),
          cidade: cidadeController.text.trim(),
          estado: estadoSelecionado,
          bairro: bairroController.text.trim(),
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
    final isEdicao = widget.comum != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Comum' : 'Cadastrar Comum'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomeController,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (value) {
                  final texto = value?.trim() ?? '';
                  if (texto.isEmpty) return 'Informe o nome';
                  if (texto.length > 100) return 'Nome deve ter no máximo 100 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cidadeController,
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (value) {
                  final texto = value?.trim() ?? '';
                  if (texto.length > 60) return 'Cidade deve ter no máximo 60 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: estadoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: estados.map((uf) {
                  return DropdownMenuItem<String>(
                    value: uf,
                    child: Text(uf),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    estadoSelecionado = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: bairroController,
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (value) {
                  final texto = value?.trim() ?? '';
                  if (texto.length > 60) return 'Bairro deve ter no máximo 60 caracteres';
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