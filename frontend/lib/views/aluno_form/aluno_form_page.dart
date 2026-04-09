import 'package:flutter/material.dart';
import '../../models/aluno.dart';

class AlunoFormPage extends StatefulWidget {
  final Aluno? aluno;

  const AlunoFormPage({super.key, this.aluno});

  @override
  State<AlunoFormPage> createState() => _AlunoFormPageState();
}

class _AlunoFormPageState extends State<AlunoFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController comumController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 🔥 Se for edição, preenche os campos
    if (widget.aluno != null) {
      nomeController.text = widget.aluno!.nome;
      comumController.text = widget.aluno!.comum ?? '';
    }
  }

  void salvar() {
    if (_formKey.currentState!.validate()) {
      final novoAluno = Aluno(
        id: widget.aluno?.id ?? DateTime.now().millisecondsSinceEpoch,
        nome: nomeController.text,
        comum: comumController.text,
      );

      print('Aluno salvo: ${novoAluno.nome}');

      Navigator.pop(context, novoAluno);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.aluno != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Aluno' : 'Cadastrar Aluno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nome
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Comum
              TextFormField(
                controller: comumController,
                decoration: const InputDecoration(
                  labelText: 'Comum',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: salvar,
                child: Text(isEdicao ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}