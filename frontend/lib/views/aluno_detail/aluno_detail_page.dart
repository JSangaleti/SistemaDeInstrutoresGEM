import 'package:flutter/material.dart';

import '../../models/aluno.dart';
import '../../services/aluno_service.dart';
import '../aluno_form/aluno_form_page.dart';

class AlunoDetailPage extends StatefulWidget {
  final int alunoId;

  const AlunoDetailPage({
    super.key,
    required this.alunoId,
  });

  @override
  State<AlunoDetailPage> createState() => _AlunoDetailPageState();
}

class _AlunoDetailPageState extends State<AlunoDetailPage> {
  final AlunoService service = AlunoService();

  Aluno? aluno;
  bool loading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarAluno();
  }

  Future<void> carregarAluno() async {
    setState(() {
      loading = true;
      erro = null;
    });

    try {
      final resultado = await service.getAlunoById(widget.alunoId);

      setState(() {
        aluno = resultado;
        loading = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        loading = false;
      });
    }
  }

  Future<void> editarAluno() async {
    final alunoAtual = aluno;

    if (alunoAtual == null) return;

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlunoFormPage(aluno: alunoAtual),
      ),
    );

    if (resultado == true) {
      await carregarAluno();
    }
  }

  @override
  Widget build(BuildContext context) {
    final alunoAtual = aluno;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do aluno'),
        actions: [
          IconButton(
            onPressed: carregarAluno,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          IconButton(
            onPressed: alunoAtual == null ? null : editarAluno,
            icon: const Icon(Icons.edit),
            tooltip: 'Editar aluno',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Erro ao carregar aluno:\n$erro',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : alunoAtual == null
                  ? const Center(child: Text('Aluno não encontrado.'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        CircleAvatar(
                          radius: 36,
                          child: Text(
                            alunoAtual.nome.isNotEmpty
                                ? alunoAtual.nome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            alunoAtual.nome,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _InfoCard(
                          titulo: 'CPF',
                          valor: alunoAtual.cpf ?? 'Não informado',
                          icone: Icons.badge,
                        ),
                        _InfoCard(
                          titulo: 'Comum',
                          valor: alunoAtual.comumNome ?? 'Não informada',
                          icone: Icons.location_city,
                        ),
                        _InfoCard(
                          titulo: 'Cidade',
                          valor: alunoAtual.comumCidade ?? 'Não informada',
                          icone: Icons.location_on,
                        ),
                        _InfoCard(
                          titulo: 'Estado/UF',
                          valor: alunoAtual.comumEstado ??
                              alunoAtual.comumUF ??
                              'Não informado',
                          icone: Icons.map,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: editarAluno,
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar aluno'),
                        ),
                      ],
                    ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _InfoCard({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final texto = valor.trim().isEmpty ? 'Não informado' : valor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icone),
        title: Text(titulo),
        subtitle: Text(
          texto,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}